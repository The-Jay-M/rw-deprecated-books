using UnityEngine;
using UnityEngine.XR.ARFoundation;

namespace Razeware.ARBook
{
	[RequireComponent(typeof(ARSessionOrigin))]
	public class RotateContent : MonoBehaviour
    {
        public Transform pivotTransform;
        public VirtualJoystick rotateJoystick;
        public float rotationSpeed;

        private float currentAngle;
        private ARSessionOrigin arSessionOrigin;
        
        void Start()
        {
            arSessionOrigin = GetComponent<ARSessionOrigin>();
            currentAngle = 0;
        }

        void Update()
        {
            currentAngle += rotateJoystick.Horizontal() * rotationSpeed * Time.deltaTime;

            arSessionOrigin.MakeContentAppearAt(pivotTransform, Quaternion.AngleAxis(currentAngle, Vector3.up));
        }
    }
}