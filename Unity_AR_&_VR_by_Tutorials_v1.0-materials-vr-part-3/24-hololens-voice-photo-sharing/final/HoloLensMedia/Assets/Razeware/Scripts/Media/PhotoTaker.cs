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
using UnityEngine.XR.WSA.WebCam;
using System.Linq;
using System.Collections.Generic;
using HoloToolkit.Unity;

/**
 * Script to use the PhotoCapture API to take and save an image.
 * See also:
 * https://docs.microsoft.com/en-us/windows/mixed-reality/locatable-camera-in-unity
 */
public class PhotoTaker : Singleton<PhotoTaker> {

    public GameObject Photo;

    // The API to asynchronously capture photos from the forward camera.
    PhotoCapture photoCaptureObject = null;
    Resolution cameraResolution;

    // Render to texture or to file.
    public bool renderToTexture = true;
    public bool takePhotoOnStart = true;

    void Start()
    {
        cameraResolution = PhotoCapture.SupportedResolutions.OrderByDescending((res) => res.width * res.height).First();
        if (takePhotoOnStart)
        {
            TakePicture();
        }
    }

    // 1 Asynchronously create a PhotoCapture instance
    void OnPhotoCaptureCreated(PhotoCapture captureObject)
    {
        photoCaptureObject = captureObject;

        CameraParameters c = new CameraParameters();
        // 1. Use full opacity to get a mixed image.
        c.hologramOpacity = 1.0f;
        // 2. Set width, height, and a pixel format.
        c.cameraResolutionWidth = cameraResolution.width;
        c.cameraResolutionHeight = cameraResolution.height;
        c.pixelFormat = CapturePixelFormat.BGRA32;
        // 3. Hook in the next async callback
        photoCaptureObject.StartPhotoModeAsync(c, OnStartPhotoCapture);
    }

    // 2 Start capture
    void OnStartPhotoCapture(PhotoCapture.PhotoCaptureResult result)
    {
        if (result.success)
        {
            if (renderToTexture)
            {
                photoCaptureObject.TakePhotoAsync(OnCapturedPhotoToMemory);
            }
            else
            {
                string filename = string.Format(@"CapturedImage{0}_n.jpg", Time.time);
                string filePath = System.IO.Path.Combine(Application.persistentDataPath, filename);
                photoCaptureObject.TakePhotoAsync(filePath, PhotoCaptureFileOutputFormat.JPG, OnCapturedPhotoToDisk);
            }
        }
    }

    // 3 Capture to a file.
    void OnCapturedPhotoToDisk(PhotoCapture.PhotoCaptureResult result)
    {
        photoCaptureObject.StopPhotoModeAsync(OnStoppedPhotoMode);
    }

    // 4 Capture photo to a texture.
    void OnCapturedPhotoToMemory(PhotoCapture.PhotoCaptureResult result, PhotoCaptureFrame photoCaptureFrame)
    {
        // Copy the raw image data into the target texture
        Texture2D targetTexture = new Texture2D(cameraResolution.width, cameraResolution.height);
        photoCaptureFrame.UploadImageDataToTexture(targetTexture);

        // Create a GameObject to which the texture can be applied
        GameObject photo = Instantiate(Photo);
        Renderer quadRenderer = photo.GetComponent<Renderer>() as Renderer;
        quadRenderer.material = new Material(Shader.Find("MixedRealityToolkit/Standard"));

        // Set it's position to be in front of the camera view.
        Transform camera = CameraCache.Main.transform;
        photo.transform.position = camera.position + camera.forward * 1f;
        photo.transform.rotation = Quaternion.LookRotation(camera.forward);
        quadRenderer.material.SetTexture("_MainTex", targetTexture);

        // Deactivate the camera
        photoCaptureObject.StopPhotoModeAsync(OnStoppedPhotoMode);
    }

    // 5 Cleanup code
    void OnStoppedPhotoMode(PhotoCapture.PhotoCaptureResult result)
    {
        photoCaptureObject.Dispose();
        photoCaptureObject = null;
        Destroy(this);
    }

    // 6 provide a way for other behavior(s) to programmatically take a photo.
    public void TakePicture()
    {
        // Set the first parameter true to include holograms.
        PhotoCapture.CreateAsync(true, OnPhotoCaptureCreated);
    }
}
