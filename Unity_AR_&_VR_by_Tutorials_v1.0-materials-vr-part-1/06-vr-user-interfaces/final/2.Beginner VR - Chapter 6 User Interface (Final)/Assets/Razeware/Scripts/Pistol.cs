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

public class Pistol : VRTK_InteractableObject
{
    [SerializeField] public Transform gunEnd;

    [SerializeField] public float bulletSpeed = 200f;
    [SerializeField] public float bulletLife = 5f;
    [SerializeField] public int bulletClipSize = 16;
    [SerializeField] public int bulletsLeftInClip = 16;

    [SerializeField] public GameObject bullet;

    private VRTK_ControllerEvents controllerEvents;

    [SerializeField] private PistolRack slide;
    [SerializeField] private Rigidbody slideRigidbody;
    [SerializeField] private Collider slideCollider;

    [SerializeField] private GameObject ammoTooltipGameObject;

    private VRTK_ObjectTooltip ammoTooltip;

    void Start()
    {
        ammoTooltip = ammoTooltipGameObject.GetComponent<VRTK_ObjectTooltip>();
    }

    protected override void Awake()
    {
        base.Awake();
        if (bullet != null)
        {
            bullet.SetActive(false);
        }

        if (slide != null)
        {
            slideRigidbody = slide.GetComponent<Rigidbody>();
            slideCollider = slide.GetComponent<Collider>();
        }

        slideCollider.enabled = false;

        if (ammoTooltipGameObject != null)
        {
            ammoTooltipGameObject.SetActive(false);
        }
    }

    protected override void Update()
    {
        base.Update();
    }

    private void ToggleCollision(Rigidbody objRB, Collider objCol, bool state)
    {
        objRB.isKinematic = state;
        objCol.isTrigger = state;
    }

    private void ToggleSlide(bool state)
    {
        if (!state)
        {
            slide.ForceStopInteracting();
        }
        slide.enabled = state;
        slide.isGrabbable = state;
        ToggleCollision(slideRigidbody, slideCollider, state);
    }

    public override void Grabbed(VRTK_InteractGrab currentGrabbingObject)
    {
        base.Grabbed(currentGrabbingObject);

        slideCollider.enabled = true;

        if (ammoTooltipGameObject != null)
        {
            ammoTooltipGameObject.SetActive(true);
        }

        if (ammoTooltip != null)
        {
            ammoTooltip.UpdateText(bulletsLeftInClip + " / " + bulletClipSize);
        }

        controllerEvents = currentGrabbingObject.GetComponent<VRTK_ControllerEvents>();

        ToggleSlide(true);

        slide.reloadAction += Reloaded;

        if (VRTK_DeviceFinder.GetControllerHand(currentGrabbingObject.controllerEvents.gameObject) == SDK_BaseController.ControllerHand.Left)
        {
            allowedTouchControllers = AllowedController.LeftOnly;
            allowedUseControllers = AllowedController.LeftOnly;
            slide.allowedGrabControllers = AllowedController.RightOnly;
        }
        else if (VRTK_DeviceFinder.GetControllerHand(currentGrabbingObject.controllerEvents.gameObject) == SDK_BaseController.ControllerHand.Right)
        {
            allowedTouchControllers = AllowedController.RightOnly;
            allowedUseControllers = AllowedController.RightOnly;
            slide.allowedGrabControllers = AllowedController.LeftOnly;
        }
    }

    public override void Ungrabbed(VRTK_InteractGrab previousGrabbingObject)
    {
        base.Ungrabbed(previousGrabbingObject);

        slideCollider.enabled = false;

        if (ammoTooltipGameObject != null)
        {
            ammoTooltipGameObject.SetActive(false);
        }

        ToggleSlide(false);

        slide.reloadAction -= Reloaded;

        allowedTouchControllers = AllowedController.Both;
        allowedUseControllers = AllowedController.Both;
        slide.allowedGrabControllers = AllowedController.Both;

        controllerEvents = null;
    }

    public override void StartUsing(VRTK_InteractUse currentUsingObject)
    {
        base.StartUsing(currentUsingObject);

        if (bulletsLeftInClip > 0)
        {
            slide.Fire();
            FireBullet();

            if (ammoTooltip != null)
            {
                ammoTooltip.UpdateText(bulletsLeftInClip + " / " + bulletClipSize);
            }

            bulletsLeftInClip--;

            VRTK_ControllerHaptics.TriggerHapticPulse(VRTK_ControllerReference.GetControllerReference(controllerEvents.gameObject), 0.63f, 0.2f, 0.01f);
        }
        else
        {
            slide.needsReloading = true;

            if (ammoTooltip != null)
            {
                ammoTooltip.UpdateText("Reload");
            }
        }
    }

    private void FireBullet()
    {
        GameObject bulletClone = Instantiate(bullet, bullet.transform.position, bullet.transform.rotation) as GameObject;
        bulletClone.transform.localScale = new Vector3(5, 5, 5);
        bulletClone.SetActive(true);
        Rigidbody rb = bulletClone.GetComponent<Rigidbody>();
        rb.AddForce(gunEnd.transform.forward * bulletSpeed);
        Destroy(bulletClone, bulletLife);
    }

    private void Reloaded()
    {
        bulletsLeftInClip = bulletClipSize;
        ammoTooltip.UpdateText(bulletsLeftInClip + " / " + bulletClipSize);
    }
}
