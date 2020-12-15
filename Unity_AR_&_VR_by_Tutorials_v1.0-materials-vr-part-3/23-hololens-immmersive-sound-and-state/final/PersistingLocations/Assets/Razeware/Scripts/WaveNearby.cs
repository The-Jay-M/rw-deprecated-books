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
using System.Collections.Generic;
using UnityEngine;

/**
* This MonoBehaviour will cause the character to switch to a 'Wave' state in the 
* animator controller whenever the wearer of the HMD is within range of the character.
* 
*/
public class WaveNearby : MonoBehaviour
{
    // If the camera (headset) is with 1.5 meters, the character will wave hello.
    public float helloDistance = 1.5f;

    private GameObject myHeadset;   // We will assign the headset to the Mixed Reality Camera
    private Animator myAnimator;            // We will assign animator to a component in the attached GameObject.

    int IDLE = 0;
    int WAVING = 1;

    // Use this for initialization
    void Start()
    {
        // Find the camera for the user's headset.
        myHeadset = GameObject.Find("MixedRealityCamera") as GameObject;

        // Animator is a component on the GameObject of this script.
        myAnimator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        int layer = 0; // Base Layer
        AnimatorStateInfo stateInfo = myAnimator.GetCurrentAnimatorStateInfo(layer);

        float distance = Vector3.Distance(myHeadset.transform.position, gameObject.transform.position);

        if (distance < helloDistance)
        {
            myAnimator.SetInteger("CurrentState", WAVING);
        }
        else
        {
            myAnimator.SetInteger("CurrentState", IDLE);
        }
    }
}