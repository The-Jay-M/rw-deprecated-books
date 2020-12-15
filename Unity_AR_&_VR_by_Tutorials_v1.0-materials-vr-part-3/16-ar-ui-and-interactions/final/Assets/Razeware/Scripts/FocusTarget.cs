using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.XR;
using UnityEngine.XR.ARFoundation;

namespace Razeware.ARBook
{
    public class FocusTarget : MonoBehaviour
    {

        public enum FocusState
        {
            Initializing,
            Finding,
            Found
        }

        public ARSessionOrigin arSessionOrigin;
        public GameObject findingTarget;
        public GameObject foundTarget;

        //for editor version
        public float maxRayDistance = 30.0f;
        public float findingTargetDist = 1.0f;

        private FocusState targetState;

        public FocusState TargetState
        {
            get { return targetState; }
            set
            {
                targetState = value;
                foundTarget.SetActive(targetState == FocusState.Found);
                findingTarget.SetActive(targetState != FocusState.Found);
            }
        }

        bool trackingInitialized;

        // Use this for initialization
        void Start()
        {
            TargetState = FocusState.Initializing;
            trackingInitialized = true;
        }


        private void TransformFocusTarget(Pose hitPose)
        {
            //move the focus target to where the hit is located
            foundTarget.transform.position = hitPose.position;
            foundTarget.transform.rotation = hitPose.rotation;

        }


        private bool HitTestWithTrackableType(Vector3 screenPositon, TrackableType trackableTypeMask)
        {
            List<ARRaycastHit> hitResults = new List<ARRaycastHit>();
            if (arSessionOrigin.Raycast(screenPositon, hitResults, trackableTypeMask))
            {
                foreach (var hitResult in hitResults)
                {
                    TransformFocusTarget(hitResult.sessionRelativePose);  //session relative pose
                    return true;
                }
            }
            return false;
        }


        // Update is called once per frame
        void Update()
        {

            //use center of screen for focusing
            Vector3 center = new Vector3(Screen.width / 2, Screen.height / 2, findingTargetDist);

            // prioritize trackable types to hit test against
            TrackableType[] trackableTypes = {
                TrackableType.PlaneWithinPolygon	
            };

            //check for each trackable types in order
            foreach (TrackableType trackableType in trackableTypes)
            {
                if (HitTestWithTrackableType(center, trackableType))
                {
                    TargetState = FocusState.Found;
                    return;
                }
            }

            //if you got here, we have not found a plane, so if camera is facing below horizon, display the focus "finding" target
            if (trackingInitialized)
            {
                TargetState = FocusState.Finding;

                //check camera forward is facing downward
                if (Vector3.Dot(arSessionOrigin.camera.transform.forward, Vector3.down) > 0.1f)
                {

                    //position the focus finding target a distance from camera and facing up
                    findingTarget.transform.position = arSessionOrigin.camera.ScreenToWorldPoint(center);

                    //vector from camera to focustarget
                    Vector3 vecToCamera = findingTarget.transform.position - arSessionOrigin.camera.transform.position;

                    //find vector that is orthogonal to camera vector and up vector
                    Vector3 vecOrthogonal = Vector3.Cross(vecToCamera, Vector3.up);

                    //find vector orthogonal to both above and up vector to find the forward vector in basis function
                    Vector3 vecForward = Vector3.Cross(vecOrthogonal, Vector3.up);


                    findingTarget.transform.rotation = Quaternion.LookRotation(vecForward, Vector3.up);

                }
                else
                {
                    //we will not display finding target if camera is not facing below horizon
                    findingTarget.SetActive(false);
                }

            }

        }


    }

}
