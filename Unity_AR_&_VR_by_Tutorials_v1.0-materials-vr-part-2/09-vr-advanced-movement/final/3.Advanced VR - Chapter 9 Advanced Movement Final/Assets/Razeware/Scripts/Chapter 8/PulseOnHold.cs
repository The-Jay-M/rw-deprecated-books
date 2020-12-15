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
using VRTK;

public class PulseOnHold : VRTK_InteractableObject
{
    public float pulseInterval = 2f;
    public float pulseDuration = .2f;

    private VRTK_ControllerReference controllerReference;
    private IEnumerator pulseRoutine;

    private void OnEnable()
    {
        base.OnEnable();
        pulseRoutine = DoPulsing();
    }

    public override void Grabbed(VRTK_InteractGrab grabbingObject)
    {
        base.Grabbed(grabbingObject);
        controllerReference =
            VRTK_ControllerReference.GetControllerReference(grabbingObject.controllerEvents.gameObject);
        StartCoroutine(pulseRoutine);
    }

    public override void Ungrabbed(VRTK_InteractGrab grabbingObject)
    {
        base.Ungrabbed(grabbingObject);
        controllerReference = null;
        StopCoroutine(pulseRoutine);
    }

    IEnumerator DoPulsing()
    {
        while (gameObject.activeSelf)
        {
            VRTK_ControllerHaptics.TriggerHapticPulse(controllerReference, 0.5f, pulseDuration, 0.01f);
            yield return new WaitForSeconds(pulseInterval);
        }
    }
}
