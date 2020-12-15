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
using UnityEngine.Events;
using VRTK;

public class PistolRack : VRTK_InteractableObject
{
    private float restPosition;
    private float fireTimer = 0f;
    private float fireDistance = 0.02f;
    private float boltSpeed = 0.01f;

    [HideInInspector] public bool needsReloading;
    [HideInInspector] public UnityAction reloadAction;

    public void Fire()
    {
        fireTimer = fireDistance;
    }

    protected override void Awake()
    {
        base.Awake();
        restPosition = transform.localPosition.z;
    }

    protected override void Update()
    {
        base.Update();
        if (transform.localPosition.z >= restPosition)
        {
            transform.localPosition = new Vector3(transform.localPosition.x, transform.localPosition.y, restPosition);
        }

        if (fireTimer == 0 && transform.localPosition.z < restPosition && !IsGrabbed())
        {
            transform.localPosition = new Vector3(transform.localPosition.x, transform.localPosition.y, transform.localPosition.z + boltSpeed);
        }

        if (fireTimer > 0)
        {
            transform.localPosition = new Vector3(transform.localPosition.x, transform.localPosition.y, transform.localPosition.z - boltSpeed);
            fireTimer -= boltSpeed;
        }

        if (fireTimer < 0)
        {
            fireTimer = 0;
        }
    }

    public override void Ungrabbed(VRTK_InteractGrab previousGrabbingObject)
    {
        base.Ungrabbed(previousGrabbingObject);

        if (transform.localPosition.z < restPosition)
        {
            if (reloadAction != null)
            {
                reloadAction.Invoke();
            }
        }
    }
}
