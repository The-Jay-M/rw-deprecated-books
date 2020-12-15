/*
 * Copyright (c) 2018 Razeware LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish, 
 * distribute, sublicense, create a derivative work, and/or sell copies of the 
 * Software in any work that is designed, intended, or marketed for pedagogical or 
 * instructional purposes related to programming, coding, application development, 
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works, 
 * or sale is expressly withheld.
 *    
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
using System.Collections;
using UnityEngine;
using UnityEngine.Experimental.XR;
using UnityEngine.SceneManagement;
using UnityEngine.XR.ARFoundation;

namespace Razeware.ARBook
{
    public class PlaneChooser : MonoBehaviour
    {
        public static PlaneChooser Instance;
    
        public string lobbySceneStr;
    
        public ARSessionOrigin ARSessionOrigin;
    
        bool inMouseHandler;
        bool doneChoosingPlane;
        
        //keep some parameters of the plane you found so that you can choose where to place your game
        Vector3 tappedPosition;
        Quaternion tappedRotation;
        float tappedMinDimension;
        Camera arCamera;

        float savedCameraNear;
        float savedCameraFar;

        public Camera GetARCamera()
        {
            return arCamera;
        }
        
        void Awake()
        {
            Instance = this;
            arCamera = ARSessionOrigin.GetComponentInChildren<Camera>();
            if (arCamera == null)
            {
                arCamera = Camera.main;
            }

            savedCameraNear = arCamera.nearClipPlane;
            savedCameraFar = arCamera.farClipPlane;
        }
        
        // Use this for initialization
        void Start ()
        {
            inMouseHandler = false;
            doneChoosingPlane = false;
            DontDestroyOnLoad(gameObject);  //dont destroy this when you load the next scene
        }

        void Update()
        {
            if (Input.GetMouseButtonDown(0) && !inMouseHandler)
            {
                StartCoroutine(MouseHandler());
            }
    
            if (doneChoosingPlane) 
            {
                 LoadLobbyScene ();
            }
        }
    
        void LoadLobbyScene()
        {
            SceneManager.LoadScene(lobbySceneStr);
            enabled = false;
        }
    
    
        IEnumerator MouseHandler()
        {
            inMouseHandler = true;
            
            Ray ray = arCamera.ScreenPointToRay(Input.mousePosition);
    
            RaycastHit rayHit;
            if (Physics.Raycast (ray, out rayHit))
            {
                ARPlane arPlane = rayHit.collider.gameObject.GetComponent<ARPlane>();
    
                if (arPlane != null)
                {
                    bool isHorizontal = (arPlane.boundedPlane.Alignment & PlaneAlignment.Horizontal) != 0;
                    if (isHorizontal)
                    {
                        tappedPosition = arPlane.boundedPlane.Pose.position;
                        tappedRotation = arPlane.boundedPlane.Pose.rotation;
                        tappedMinDimension = Mathf.Min(arPlane.boundedPlane.Width, arPlane.boundedPlane.Height);
    
                        doneChoosingPlane = true;
                    }
                    
                }
            }
    
            inMouseHandler = false;
            yield return null;
        }
    
        public void PlaceOnSelectedPlane(Transform contentParent, float contentDimension)
        {
            ARSessionOrigin.MakeContentAppearAt(contentParent,tappedPosition,tappedRotation);
            ARSessionOrigin.transform.localScale = Vector3.one * (contentDimension/tappedMinDimension);
            arCamera.nearClipPlane = savedCameraNear * (contentDimension / tappedMinDimension);
            arCamera.farClipPlane = savedCameraFar * (contentDimension / tappedMinDimension);

            ARPlaneManager arPlaneManager = ARSessionOrigin.GetComponent<ARPlaneManager>();
            arPlaneManager.planePrefab = null;  //do not generate any more visible planes 
            ARSessionOrigin.trackablesParent.gameObject.SetActive(false); //turn off existing visible planes
        }
    }
}