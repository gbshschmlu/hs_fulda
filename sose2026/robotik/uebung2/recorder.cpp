#include <fstream>
#include <memory>

#include "nav_msgs/msg/odometry.hpp"
#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/imu.hpp"
#include "std_msgs/msg/string.hpp"

using std::placeholders::_1;

class TrajectoryRecorder : public rclcpp::Node {
public:
  TrajectoryRecorder(std::ofstream &odom_out, std::ofstream &imu_out)
      : Node("trajectory_recorder"), odom_out_(odom_out), imu_out_(imu_out) {
    // Odometrie Subscriber aufsetzen
    odom_sub_ = this->create_subscription<nav_msgs::msg::Odometry>(
        "/odom", 10, std::bind(&TrajectoryRecorder::odom_callback, this, _1));
  }

private:
  void odom_callback(const nav_msgs::msg::Odometry::SharedPtr msg) {
    // x und y Position aus dem Odometry-Message extrahieren
    double x = msg->pose.pose.position.x;
    double y = msg->pose.pose.position.y;

    // In die Datei loggen
    odom_out_ << x << " " << y << std::endl;
  }

  std::ofstream &odom_out_;
  std::ofstream &imu_out_;

  // Member für den Subscriber
  rclcpp::Subscription<nav_msgs::msg::Odometry>::SharedPtr odom_sub_;
};

int main(int argc, char **argv) {
  std::ofstream odom_out("odometry.txt");
  std::ofstream imu_out("imu.txt");

  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<TrajectoryRecorder>(odom_out, imu_out));
  rclcpp::shutdown();

  return 0;
}
