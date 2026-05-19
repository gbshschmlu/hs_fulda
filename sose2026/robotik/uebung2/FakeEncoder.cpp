#include <chrono>
#include <cmath>
#include <functional>
#include <memory>
#include <string>
#include <vector>

#include <geometry_msgs/msg/twist.hpp>

#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/string.hpp"
#include <nav_msgs/msg/odometry.hpp>
#include <sensor_msgs/msg/joint_state.hpp>

#include <tf2/convert.h>
#include <tf2_ros/transform_broadcaster.h>
#include <tf2_ros/transform_listener.h>

using namespace std::chrono_literals;
using std::placeholders::_1;

struct VolksbotParameters {
  double wheel_radius = 0.0985;
  double axis_length = 0.41;
  int64_t gear_ratio = 74;
  int64_t max_vel_l = 8250;
  int64_t max_vel_r = 8400;
  int64_t max_acc_l = 10000;
  int64_t max_acc_r = 10000;
  int64_t num_wheels = 4;
};

class FakeEncoder : public rclcpp::Node {
public:
  FakeEncoder()
      : Node("fake_encoder"), x_(0), y_(0), theta_(0), rotation_l_(0),
        rotation_r_(0) {
    // Joint names of our URDF model
    joint_names_ = {"left_front_wheel_joint", "left_rear_wheel_joint",
                    "right_front_wheel_joint", "right_rear_wheel_joint"};

    // Setup publishers
    joint_pub_ = this->create_publisher<sensor_msgs::msg::JointState>(
        "joint_states", 10);

    // Setup Timer for 100ms
    timer_ = this->create_wall_timer(
        100ms, std::bind(&FakeEncoder::timer_callback, this));
  }

private:
  void timer_callback() {
    // 1 Grad in Radiant umrechnen
    double step = M_PI / 180.0;

    // Winkel inkrementieren
    rotation_l_ += step;
    if (rotation_l_ > 2.0 * M_PI)
      rotation_l_ -= 2.0 * M_PI;

    rotation_r_ += step;
    if (rotation_r_ > 2.0 * M_PI)
      rotation_r_ -= 2.0 * M_PI;

    // Message befuellen
    auto msg = sensor_msgs::msg::JointState();
    msg.header.stamp = this->now();
    msg.name = joint_names_;
    msg.position = {rotation_l_, rotation_l_, rotation_r_, rotation_r_};

    // Publizieren
    joint_pub_->publish(msg);
  }

  double x_;
  double y_;
  double theta_;
  double rotation_l_;
  double rotation_r_;
  VolksbotParameters params_;
  std::vector<std::string> joint_names_;

  // Member für Publisher & Timer
  rclcpp::Publisher<sensor_msgs::msg::JointState>::SharedPtr joint_pub_;
  rclcpp::TimerBase::SharedPtr timer_;
};

int main(int argc, char *argv[]) {
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<FakeEncoder>());
  rclcpp::shutdown();
  return 0;
}
