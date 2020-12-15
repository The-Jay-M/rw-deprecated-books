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

using UnityEngine;
using UnityEngine.XR.ARFoundation;

namespace Razeware.ARBook
{

	public class TapAddsGameObject : MonoBehaviour 
    {

        public ARSessionOrigin arSessionOrigin;
		public GameObject virtualObjectPrefab;

		void Start()
		{
            if (virtualObjectPrefab == null || arSessionOrigin == null)
            {
				Debug.LogError ("GameObject references missing - needed for the functionality of this script!");
			}
		}

		// Update is called once per frame
		void Update () 
		{
			if (Input.GetMouseButtonDown(0))
			{
				//user tapped the screen this frame (or clicked mouse)
				//create an object from prefab and parent to the GO that this script is attached to
                GameObject virtualObj = Instantiate<GameObject>(virtualObjectPrefab, gameObject.transform);

                //move the virtual object to where the camera is located
                Camera trackedCamera = arSessionOrigin.camera;
				virtualObj.transform.position = trackedCamera.transform.position + trackedCamera.transform.forward * 0.4f;  //make it appear a bit in front of camera
				virtualObj.transform.rotation = trackedCamera.transform.rotation;

			}
		}
	}
}
