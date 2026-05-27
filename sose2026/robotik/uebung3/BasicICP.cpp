#include <sensor_msgs/msg/laser_scan.hpp>
#include <sensor_msgs/msg/point_cloud.hpp>
#include <sensor_msgs/msg/point_cloud2.hpp>

#include <message_filters/subscriber.h>
#include <message_filters/sync_policies/approximate_time.h>
#include <message_filters/synchronizer.h>
#include <message_filters/time_synchronizer.h>

#include <laser_geometry/laser_geometry.hpp>
#include <sensor_msgs/point_cloud2_iterator.hpp>
#include <visualization_msgs/msg/marker.hpp>

#include <tf2/LinearMath/Quaternion.h>
#include <tf2/LinearMath/Transform.h>
#include <tf2/convert.h>
#include <tf2_geometry_msgs/tf2_geometry_msgs.hpp>
#include <tf2_ros/transform_broadcaster.h>

#include <cmath>
#include <limits>

using namespace std::chrono_literals;

class BasicICPNode : public rclcpp::Node {
public:
  BasicICPNode() : rclcpp::Node("basic_icp_node"), initialized_(false) {
    model_sub_.subscribe(this, "/model");
    scan_sub_.subscribe(this, "/scan");

    syncApproximate_ =
        std::make_shared<message_filters::Synchronizer<approximate_policy>>(
            approximate_policy(10), model_sub_, scan_sub_);
    syncApproximate_->registerCallback(&BasicICPNode::laserCallback, this);

    marker_pub_ = this->create_publisher<visualization_msgs::msg::Marker>(
        "/icp_correspondences", 10);
    tf_broadcaster_ = std::make_shared<tf2_ros::TransformBroadcaster>(this);
  }

private:
  message_filters::Subscriber<sensor_msgs::msg::LaserScan> model_sub_;
  message_filters::Subscriber<sensor_msgs::msg::LaserScan> scan_sub_;
  typedef message_filters::sync_policies::ApproximateTime<
      sensor_msgs::msg::LaserScan, sensor_msgs::msg::LaserScan>
      approximate_policy;
  std::shared_ptr<message_filters::Synchronizer<approximate_policy>>
      syncApproximate_;

  laser_geometry::LaserProjection projector_;

  rclcpp::Publisher<visualization_msgs::msg::Marker>::SharedPtr marker_pub_;
  std::shared_ptr<tf2_ros::TransformBroadcaster> tf_broadcaster_;
  rclcpp::TimerBase::SharedPtr timer_;

  bool initialized_;
  sensor_msgs::msg::PointCloud2::SharedPtr model_cloud_;
  sensor_msgs::msg::PointCloud2::SharedPtr current_scan_cloud_;
  tf2::Transform cumulative_transform_;

  using CorrPair =
      std::pair<geometry_msgs::msg::Point32, geometry_msgs::msg::Point32>;
  using CorrVec = std::vector<CorrPair>;

  void
  calcICPCorrespondences(sensor_msgs::msg::PointCloud2::SharedPtr scan_cloud,
                         sensor_msgs::msg::PointCloud2::SharedPtr model_cloud,
                         CorrVec &point_correspondences, double &eps) {
    sensor_msgs::PointCloud2ConstIterator<float> iter_scan_x(*scan_cloud, "x");
    sensor_msgs::PointCloud2ConstIterator<float> iter_scan_y(*scan_cloud, "y");

    eps = 0.0;
    point_correspondences.clear();

    for (; iter_scan_x != iter_scan_x.end(); ++iter_scan_x, ++iter_scan_y) {
      float min_dist_sq = std::numeric_limits<float>::max();
      geometry_msgs::msg::Point32 best_model_pt;
      geometry_msgs::msg::Point32 scan_pt;

      scan_pt.x = *iter_scan_x;
      scan_pt.y = *iter_scan_y;
      scan_pt.z = 0.0;

      sensor_msgs::PointCloud2ConstIterator<float> iter_model_x(*model_cloud,
                                                                "x");
      sensor_msgs::PointCloud2ConstIterator<float> iter_model_y(*model_cloud,
                                                                "y");

      for (; iter_model_x != iter_model_x.end();
           ++iter_model_x, ++iter_model_y) {
        float dist_sq = std::pow(scan_pt.x - *iter_model_x, 2) +
                        std::pow(scan_pt.y - *iter_model_y, 2);
        if (dist_sq < min_dist_sq) {
          min_dist_sq = dist_sq;
          best_model_pt.x = *iter_model_x;
          best_model_pt.y = *iter_model_y;
          best_model_pt.z = 0.0;
        }
      }
      point_correspondences.push_back({best_model_pt, scan_pt});
      eps += min_dist_sq;
    }
  }

  tf2::Transform calcTransFormation(const CorrVec &point_correspondences) {
    double cx = 0.0, cy = 0.0, cpx = 0.0, cpy = 0.0;
    int N = point_correspondences.size();

    // 1. Schwerpunkte berechnen
    for (const auto &pair : point_correspondences) {
      cx += pair.first.x;
      cy += pair.first.y; // Modell c
      cpx += pair.second.x;
      cpy += pair.second.y; // Scan c'
    }
    cx /= N;
    cy /= N;
    cpx /= N;
    cpy /= N;

    // 2. Kovarianzen berechnen
    double Sxx = 0.0, Syy = 0.0, Sxy = 0.0, Syx = 0.0;
    for (const auto &pair : point_correspondences) {
      double px = pair.first.x, py = pair.first.y;
      double ppx = pair.second.x, ppy = pair.second.y;
      Sxx += (px - cx) * (ppx - cpx);
      Syy += (py - cy) * (ppy - cpy);
      Sxy += (px - cx) * (ppy - cpy);
      Syx += (py - cy) * (ppx - cpx);
    }

    // 3. Transformation berechnen (Lu/Milios)
    double theta = std::atan2(Syx - Sxy, Sxx + Syy);
    double tx = cx - (cpx * std::cos(theta) - cpy * std::sin(theta));
    double ty = cy - (cpx * std::sin(theta) + cpy * std::cos(theta));

    tf2::Transform transform;
    tf2::Quaternion q;
    q.setRPY(0, 0, theta);
    transform.setRotation(q);
    transform.setOrigin(tf2::Vector3(tx, ty, 0.0));

    return transform;
  }

  void transformPointCloud(sensor_msgs::msg::PointCloud2::SharedPtr in_cloud,
                           sensor_msgs::msg::PointCloud2::SharedPtr out_cloud,
                           tf2::Transform &transform) {
    *out_cloud = *in_cloud; // Kopiert Metadaten & Größe

    sensor_msgs::PointCloud2Iterator<float> iter_out_x(*out_cloud, "x");
    sensor_msgs::PointCloud2Iterator<float> iter_out_y(*out_cloud, "y");
    sensor_msgs::PointCloud2Iterator<float> iter_out_z(*out_cloud, "z");

    for (; iter_out_x != iter_out_x.end();
         ++iter_out_x, ++iter_out_y, ++iter_out_z) {
      tf2::Vector3 pt(*iter_out_x, *iter_out_y, *iter_out_z);
      tf2::Vector3 pt_transformed = transform * pt;
      *iter_out_x = pt_transformed.x();
      *iter_out_y = pt_transformed.y();
      *iter_out_z = pt_transformed.z();
    }
  }

  void publishMarkers(const CorrVec &correspondences) {
    visualization_msgs::msg::Marker marker;
    marker.header.frame_id = "model";
    marker.header.stamp = this->now();
    marker.ns = "icp_lines";
    marker.id = 0;
    marker.type = visualization_msgs::msg::Marker::LINE_LIST;
    marker.action = visualization_msgs::msg::Marker::ADD;
    marker.scale.x = 0.01; // Liniendicke
    marker.color.a = 1.0;
    marker.color.r = 1.0;
    marker.color.g = 0.0;
    marker.color.b = 0.0; // Rot

    for (const auto &pair : correspondences) {
      geometry_msgs::msg::Point p_model;
      p_model.x = pair.first.x;
      p_model.y = pair.first.y;
      p_model.z = pair.first.z;

      geometry_msgs::msg::Point p_scan;
      p_scan.x = pair.second.x;
      p_scan.y = pair.second.y;
      p_scan.z = pair.second.z;

      marker.points.push_back(p_model);
      marker.points.push_back(p_scan);
    }
    marker_pub_->publish(marker);
  }

  void icpIteration() {
    if (!initialized_)
      return;

    CorrVec correspondences;
    double eps = 0.0;

    // 1. Finde Korrespondenzen
    calcICPCorrespondences(current_scan_cloud_, model_cloud_, correspondences,
                           eps);
    RCLCPP_INFO(this->get_logger(), "ICP Fehler (epsilon): %f", eps);

    // 2. Publishe Marker für RViz
    publishMarkers(correspondences);

    // 3. Berechne den neuen Transformations-Schritt
    tf2::Transform delta_transform = calcTransFormation(correspondences);

    // 4. Update die kumulierte Gesamtransformation
    cumulative_transform_ = delta_transform * cumulative_transform_;

    // 5. Transformiere die aktuelle Scan-Cloud für den nächsten Schritt
    sensor_msgs::msg::PointCloud2::SharedPtr next_scan_cloud(
        new sensor_msgs::msg::PointCloud2);
    transformPointCloud(current_scan_cloud_, next_scan_cloud, delta_transform);
    current_scan_cloud_ = next_scan_cloud;

    // 6. Sende die TF Transformation an ROS
    geometry_msgs::msg::TransformStamped tf_msg;
    tf_msg.header.stamp = this->now();
    tf_msg.header.frame_id = "model";
    tf_msg.child_frame_id = "laser";

    tf_msg.transform.translation.x = cumulative_transform_.getOrigin().x();
    tf_msg.transform.translation.y = cumulative_transform_.getOrigin().y();
    tf_msg.transform.translation.z = cumulative_transform_.getOrigin().z();
    tf_msg.transform.rotation = tf2::toMsg(cumulative_transform_.getRotation());

    tf_broadcaster_->sendTransform(tf_msg);
  }

  void laserCallback(sensor_msgs::msg::LaserScan::SharedPtr scan,
                     sensor_msgs::msg::LaserScan::SharedPtr model) {
    // Grabben den Scan nur beim allerersten Callback und starten dann die
    // Iteration
    if (!initialized_) {
      sensor_msgs::msg::PointCloud2::SharedPtr scan_cloud(
          new sensor_msgs::msg::PointCloud2);
      sensor_msgs::msg::PointCloud2::SharedPtr model_cloud(
          new sensor_msgs::msg::PointCloud2);

      projector_.projectLaser(*model, *model_cloud);
      projector_.projectLaser(*scan, *scan_cloud);

      model_cloud_ = model_cloud;
      current_scan_cloud_ = scan_cloud;
      cumulative_transform_.setIdentity();
      initialized_ = true;

      RCLCPP_INFO(this->get_logger(),
                  "Scans empfangen. Starte ICP-Iteration (0.25 Hz)...");

      // Timer feuert alle 4 Sekunden (0.25 Hz) die icpIteration Methode
      timer_ = this->create_wall_timer(
          4s, std::bind(&BasicICPNode::icpIteration, this));
    }
  }
};

int main(int argc, char **argv) {
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<BasicICPNode>());
  rclcpp::shutdown();
  return 0;
}
