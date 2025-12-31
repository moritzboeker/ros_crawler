import os

from launch import LaunchDescription
from launch_ros.actions import LifecycleNode
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare
from launch.actions import DeclareLaunchArgument
from launch.actions import LogInfo
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution

def generate_launch_description():
    driver_node = LifecycleNode(package='ydlidar_ros2_driver',
                                executable='ydlidar_ros2_driver_node',
                                name='ydlidar_ros2_driver_node',
                                output='screen',
                                emulate_tty=True,
                                parameters=[PathJoinSubstitution([FindPackageShare('bringup'), 'config', 'ydlidar_x2.yaml'])],
                                namespace='/',
                                )
    tf2_node = Node(package='tf2_ros',
                    executable='static_transform_publisher',
                    name='static_tf_pub_laser',
                    arguments=['0', '0', '0.02','0', '0', '0', '1','base_link','laser_frame'],
                    )

    pwm_node = Node(package='pwm_pca9685', 
                    executable='pca9685_node',
                    name='pwm_node',
                    remappings=[
                        ('/command', '/command'),
                    ],
                    parameters=[PathJoinSubstitution([FindPackageShare('bringup'), 'config', 'pwm_pca9685_diff_drive.yaml'])],
                    )

    return LaunchDescription([
        driver_node,
        tf2_node,
        pwm_node,
    ])

