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
using HoloToolkit.Unity.InputModule;
using HoloToolkit.Unity.Receivers;

public class MenuController : InteractionReceiver
{
    [Tooltip("Set the prefab that should be instantiated on new.")]
    public GameObject placeCharacter;

    protected override void InputDown(GameObject obj, InputEventData eventData)
    {
        eventData.Use();

        // 1 The button you will use in this scene.
        if ("NewButton".Equals(obj.name))
        {
            // Place a character and exit the menu.
            PlaceCharacter();
            Destroy(gameObject, 0.2f);
        }
    }

    // 2 Instantiate a character in front of the camera.
    private void PlaceCharacter()
    {
        GameObject character = Instantiate(placeCharacter, new Vector3(0, 0, 2), Quaternion.identity);

        // Move the character into the gaze of the camera
        Vector3 hmdPosition = Camera.main.transform.position;
        Vector3 hmdDirection = Camera.main.transform.forward;
        character.transform.position = hmdPosition + hmdDirection * 2f;
    }
}
