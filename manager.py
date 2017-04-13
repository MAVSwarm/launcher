"""
This is the manager main script.
"""

import rospy
from manager_msgs.srv import *

from Enums import operation, state

current_state = state.Idle
next_state = state.Idle


def start_gazebo():
    pass


def handle_control(req):
    global current_state, next_state
    op = req.Operation

    if current_state == state.Idle:
        if op == operation.init:
            if start_gazebo():
                next_state = state.Initialized
                return ControlResponse(True)
            else:
                return ControlResponse(False)
    elif current_state == state.Initialized:
        pass
    elif current_state == state.Running:
        pass
    elif current_state == state.Paused:
        pass
    elif current_state == state.Stopped:
        pass
    else:
        pass


def handle_get_state(req):
    return GetStateResponse(current_state, True)


def loop():
    pass


def main():
    # initialize ros node
    rospy.init_node("manager", anonymous=False)

    # initialize service
    control_service = rospy.Service('~Control', Control, handle_control)
    get_state_service = rospy.Service("~Get_State", GetState, handle_get_state)

    rospy.loginfo("manager initialized.")

    rospy.spin()


if __name__ == '__main__':
    main()
