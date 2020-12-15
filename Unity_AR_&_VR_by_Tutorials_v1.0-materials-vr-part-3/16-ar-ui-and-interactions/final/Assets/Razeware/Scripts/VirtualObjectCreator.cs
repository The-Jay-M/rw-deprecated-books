using UnityEngine;

namespace Razeware.ARBook
{
    public class VirtualObjectCreator : MonoBehaviour
    {

        public Camera trackedCamera;
        public GameObject virtualObjectPrefab;

        void Start ()
        {
            if (virtualObjectPrefab == null || trackedCamera == null) {
                Debug.LogError ("GameObject references missing - needed for the functionality of this script!");
            }
        }

        public void CreateVirtualObject ()
        {
            //user clicked the button 
            //create an object from prefab and parent to the 
            // GameObject that this script is attached to
            GameObject virtualObj = Instantiate<GameObject> (virtualObjectPrefab, gameObject.transform);

            //move the virtual object to where the camera is located
            //make it appear a bit in front of camera
            virtualObj.transform.position = trackedCamera.transform.position +
                trackedCamera.transform.forward * 0.4f; 
            
            virtualObj.transform.rotation = 
                trackedCamera.transform.rotation;
        }
    }
}
