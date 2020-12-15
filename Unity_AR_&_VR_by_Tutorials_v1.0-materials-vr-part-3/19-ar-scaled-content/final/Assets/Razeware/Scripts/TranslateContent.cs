using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Experimental.XR;
using UnityEngine.XR.ARFoundation;

namespace Razeware.ARBook
{
    [RequireComponent(typeof(ARSessionOrigin))]
    public class TranslateContent : MonoBehaviour
    {
        public Transform placementTransform;

        private ARSessionOrigin arSessionOrigin;

        private static List<ARRaycastHit> RaycastHits = new List<ARRaycastHit>();

        void Start()
        {
            arSessionOrigin = GetComponent<ARSessionOrigin>();
        }

        void Update()
        {
            //if we touched the screen, and that results in a tap on a detected plane, place content where we tapped
            if (Input.GetMouseButton(0) && !EventSystem.current.IsPointerOverGameObject(Input.GetTouch(0).fingerId) && 
                arSessionOrigin.Raycast(Input.mousePosition, RaycastHits, TrackableType.PlaneWithinBounds))
            {
                arSessionOrigin.MakeContentAppearAt(placementTransform, RaycastHits[0].pose.position);
            }
        }
    }
}