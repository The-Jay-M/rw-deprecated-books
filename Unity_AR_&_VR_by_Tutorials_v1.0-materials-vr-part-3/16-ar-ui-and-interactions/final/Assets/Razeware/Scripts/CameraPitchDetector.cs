using UnityEngine;
using UnityEngine.UI;

namespace Razeware.ARBook
{
    public class CameraPitchDetector : MonoBehaviour
    {
        public Camera trackedCamera;
        public Sprite upArrow;
        public Sprite downArrow;
        public Sprite circle;

        public Image pitchIndicator;

        void Start()
        {
            if (trackedCamera == null || upArrow == null || downArrow == null || 
                circle == null || pitchIndicator == null) 
            {
                Debug.LogError ("GameObject references missing - needed for the functionality of this script!");
            }
        }

        void Update()
        {
            //check whether the forward vector of the camera projects a positive or negative amount on to up vector
            float dotProd = Vector3.Dot (trackedCamera.transform.forward, Vector3.up);
            pitchIndicator.sprite = (dotProd > 0.01f) ? upArrow : (dotProd < -0.01f) ? 
                downArrow : circle;
        }
    }
}