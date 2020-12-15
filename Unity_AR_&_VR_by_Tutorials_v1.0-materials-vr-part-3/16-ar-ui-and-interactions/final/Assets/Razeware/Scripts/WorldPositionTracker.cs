using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.Experimental.XR;

namespace Razeware.ARBook
{
    public class WorldPositionTracker : MonoBehaviour 
    {
        /// <summary>
        /// The first-person camera being used to render the passthrough camera image (i.e. AR background).
        /// </summary>
        public Camera FirstPersonCamera;

        /// <summary>
        /// A gameobject parenting UI for displaying the messages.
        /// </summary>
        public Text messagesUI;


        // Update is called once per frame
        void Update () 
        {
            if (ARSubsystemManager.sessionSubsystem.TrackingState == TrackingState.Tracking) 
            {
                string message = "Current world position of camera is ";
                message += FirstPersonCamera.transform.position.ToString ();
                messagesUI.text = message;
            } 
            else if (ARSubsystemManager.sessionSubsystem.TrackingState == TrackingState.Unavailable) 
            {
                messagesUI.text = "Session lost tracking...";
            } 
            else 
            {
                messagesUI.text = "AR systems initializing...";
            }
        }
    }
}