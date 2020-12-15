using UnityEngine;
using UnityEngine.UI;

namespace Razeware.ARBook
{
    public class KillerSphereLogic : MonoBehaviour {

        public Material redMaterial;
        public Material greenMaterial;
        public Camera trackedCamera;
        public Text sphereMessage;
        public LayerMask sphereCollMask;
        private MeshRenderer meshRenderer;

        private bool killmode = false;

        void Start()
        {
            meshRenderer = GetComponent<MeshRenderer> ();
            ToggleKillMode ();
        }

        void ToggleKillMode()
        {
            killmode = !killmode;
            sphereMessage.text = killmode ? "Please keep away" : "Come closer here";
            meshRenderer.material = killmode ? redMaterial : greenMaterial;
        }

        // Update is called once per frame
        void Update () 
        {
            transform.LookAt (trackedCamera.transform);

            if (Input.GetMouseButtonDown (0)) 
            {
                //tapped on screen - check if you touched sphere
                Ray ray = trackedCamera.ScreenPointToRay (Input.mousePosition);

                RaycastHit rayHit;
                if (Physics.Raycast (ray, out rayHit, float.MaxValue, sphereCollMask)) 
                {
                    if (rayHit.collider.gameObject == gameObject) 
                    {
                        ToggleKillMode ();
                    }
                }
            }
        }
    }
}