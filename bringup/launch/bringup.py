import os

from launch import LaunchDescription
from launch_ros.actions import LifecycleNode
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare
from launch.actions import DeclareLaunchArgument
from launch.actions import LogInfo
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution

ydlidar_x2_cfg = PathJoinSubstitution([FindPackageShare('bringup'), 'config', 'ydlidar_x2_cfg.yaml'])
pwm_pca9685_cfg = PathJoinSubstitution([FindPackageShare('bringup'), 'config', 'pwm_pca9685_cfg.yaml'])
sparkfun_otos_cfg = PathJoinSubstitution([FindPackageShare('bringup'), 'config', 'sparkfun_otos_cfg.yaml'])

def generate_launch_description():
    ydlidar_x2_node = LifecycleNode(
                package='ydlidar_ros2_driver',
                executable='ydlidar_ros2_driver_node',
                name='ydlidar_ros2_driver_node',
                output='screen',
                emulate_tty=True,
                parameters=[ydlidar_x2_cfg],
                namespace='/',
                )
    ydliard_tf2_node = Node(
                package='tf2_ros',
                executable='static_transform_publisher',
                name='static_tf_pub_laser',
                arguments=['0', '0', '0.02','0', '0', '0', '1','base_link','laser_frame'],
                )

    pwm_pca9685_node = Node(
                package='pwm_pca9685', 
                executable='pca9685_node',
                name='pwm_node',
                remappings=[
                ('/command', '/command'),
                ],
                parameters=[pwm_pca9685_cfg],
                )

    ackermann_to_pwm_node = Node(
                package='pwm_pca9685', 
                executable='ackermann_to_pwm_node',
                name='ackermann_to_pwm_node',
                remappings=[
                ('/ackermann_cmd', '/ackermann_cmd'),
                ('/command', '/command'),
                ],
                parameters=[pwm_pca9685_cfg],
                )

    sparkfun_otos_node = Node(
                package='sparkfun_otos_driver',
                executable='otos_node',
                name='otos',
                output='screen',
                parameters=[sparkfun_otos_cfg],
                )

    return LaunchDescription([
        ydlidar_x2_node,
        ydliard_tf2_node,
        pwm_pca9685_node,
        ackermann_to_pwm_node,
        sparkfun_otos_node,
    ])

