import os

from launch import LaunchDescription
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare
from launch.substitutions import PathJoinSubstitution

vanjee_wlr719c_cfg = PathJoinSubstitution([FindPackageShare('bringup'), 'config', 'vanjee_wlr719c_cfg.yaml'])
pwm_pca9685_cfg = PathJoinSubstitution([FindPackageShare('bringup'), 'config', 'pwm_pca9685_cfg.yaml'])
sparkfun_otos_cfg = PathJoinSubstitution([FindPackageShare('bringup'), 'config', 'sparkfun_otos_cfg.yaml'])

def generate_launch_description():
    vanjee_lidar_ros2_node = Node(
                package='vanjee_lidar_sdk',
                executable='vanjee_lidar_sdk_node',
                name='vanjee_lidar_sdk_node',
                output='screen',
                emulate_tty=True,
                parameters=[{'config_path': vanjee_wlr719c_cfg}],
                namespace='/',
                )

    vanjee_lidar_tf2_node = Node(
                package='tf2_ros',
                executable='static_transform_publisher',
                name='static_tf_pub_laser',
                arguments=['0.36', '0', '0.16','0', '0', '0', '1','base_link','vanjee_lidar'],
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

    foxglove_bridge_node = Node(
                package='foxglove_bridge',
                executable='foxglove_bridge',
                name='foxglove_bridge',
                parameters=[{'port': 8765}],
                )

    return LaunchDescription([
        vanjee_lidar_ros2_node,
        vanjee_lidar_tf2_node,
        pwm_pca9685_node,
        ackermann_to_pwm_node,
        sparkfun_otos_node,
        foxglove_bridge_node,
    ])

