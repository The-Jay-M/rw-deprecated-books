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

public class DropFromAbove : MonoBehaviour
{

	public GameObject prefabToDrop;
	public float createHeight;

	private bool firstClick = true;


	// Update is called once per frame
	void Update() 
	{
		if (!isActiveAndEnabled)
		{
			return;
		}

		if (Input.GetMouseButton (0)) 
		{
			if (firstClick) 
			{
				var camera = Camera.main;

				Ray ray = camera.ScreenPointToRay(Input.mousePosition);

				// ARSubsystems generated planes are in layer ARGameObject
				int layerMask = 1 << LayerMask.NameToLayer("ARGameObject");

				RaycastHit rayHit;
				if (Physics.Raycast(ray, out rayHit, float.MaxValue, layerMask)) 
				{
					Vector3 position = rayHit.point;
					GameObject cubeGO = 
						Instantiate(prefabToDrop, 
									new Vector3(position.x, position.y + createHeight, position.z), 
									Quaternion.identity);
					Rigidbody rb = cubeGO.GetComponent<Rigidbody>();
					rb.AddTorque(new Vector3(0.5f, 0.0f, 1.0f));
				}
				firstClick = false;
			}
		} 
		else 
		{
			firstClick = true;
		}

	}
}
