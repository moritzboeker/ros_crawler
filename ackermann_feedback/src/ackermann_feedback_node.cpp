#include <memory>
#include <string>

#include <ackermann_msgs/msg/ackermann_drive_stamped.hpp>
#include <nav_msgs/msg/odometry.hpp>
#include <rclcpp/rclcpp.hpp>

using ackermann_msgs::msg::AckermannDriveStamped;
using nav_msgs::msg::Odometry;

class AckermannFeedbackNode : public rclcpp::Node
{
public:
    AckermannFeedbackNode() : Node("ackermann_feedback")
    {
        frame_id_ = this->declare_parameter("frame_id", std::string("base_link"));
        command_timeout_ = rclcpp::Duration::from_seconds(
            this->declare_parameter("command_timeout", 0.2));

        feedback_pub_ = this->create_publisher<AckermannDriveStamped>("/ackermann_feedback", 10);

        ack_cmd_sub_ = this->create_subscription<AckermannDriveStamped>(
            "/ackermann_cmd", 10,
            std::bind(&AckermannFeedbackNode::onCommand, this, std::placeholders::_1));

        odom_sub_ = this->create_subscription<Odometry>(
            "/odom", 10,
            std::bind(&AckermannFeedbackNode::onOdometry, this, std::placeholders::_1));

        RCLCPP_INFO(
            this->get_logger(),
            "publishing /ackermann_feedback in frame '%s', command timeout %.3f s",
            frame_id_.c_str(), command_timeout_.seconds());
    }

private:
    void onCommand(const AckermannDriveStamped::SharedPtr msg)
    {
        steering_angle_ = msg->drive.steering_angle;
        last_command_ = this->now();
    }

    void onOdometry(const Odometry::SharedPtr msg)
    {
        AckermannDriveStamped feedback;
        // Stamp with the odometry sample this state was derived from, so
        // consumers can align feedback with the measurement behind it.
        feedback.header.stamp = msg->header.stamp;
        feedback.header.frame_id = frame_id_;
        // nav_msgs/Odometry defines twist in child_frame_id, so linear.x is
        // the forward speed of the robot body.
        feedback.drive.speed = static_cast<float>(msg->twist.twist.linear.x);
        feedback.drive.steering_angle = currentSteeringAngle();
        feedback_pub_->publish(feedback);
    }

    float currentSteeringAngle() const
    {
        if (last_command_.nanoseconds() == 0)
        {
            return 0.0f;
        }
        // Once commands stop, the PCA9685 drops the servo channel to its
        // timeout value, so nothing holds the steering at its last angle.
        if ((this->now() - last_command_) > command_timeout_)
        {
            return 0.0f;
        }
        return steering_angle_;
    }

    std::string frame_id_;
    rclcpp::Duration command_timeout_{0, 0};
    float steering_angle_{0.0f};
    rclcpp::Time last_command_{0, 0, RCL_ROS_TIME};

    rclcpp::Publisher<AckermannDriveStamped>::SharedPtr feedback_pub_;
    rclcpp::Subscription<AckermannDriveStamped>::SharedPtr ack_cmd_sub_;
    rclcpp::Subscription<Odometry>::SharedPtr odom_sub_;
};

int main(int argc, char ** argv)
{
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<AckermannFeedbackNode>());
    rclcpp::shutdown();
    return 0;
}
