using UnityEngine;
using UnityEngine.XR.ARFoundation;

namespace Razeware.ARBook
{
    [RequireComponent(typeof(ARSessionOrigin))]
    public class ScaleContent : MonoBehaviour
    {
        public VirtualJoystick scaleJoystick;
        public float scaleSpeed;
        
        ARSessionOrigin arSessionOrigin;
        float currentScaleNumber;

        void Start()
        {
            arSessionOrigin = GetComponent<ARSessionOrigin>();
            currentScaleNumber = 0.0f;
        }

        void Update()
        {
            //the vertical axis of the virtual joystick increases and decreases a number 
            currentScaleNumber += scaleJoystick.Vertical() * scaleSpeed * Time.deltaTime;
            
            //we need to generate scale from this number (and invert it so that content appears to scale)
            float scale = currentScaleNumber < 0.0f ? 1.0f - currentScaleNumber : 1.0f / (1.0f + currentScaleNumber);
                    
            arSessionOrigin.transform.localScale =  Vector3.one * scale;	
        }
    }
}