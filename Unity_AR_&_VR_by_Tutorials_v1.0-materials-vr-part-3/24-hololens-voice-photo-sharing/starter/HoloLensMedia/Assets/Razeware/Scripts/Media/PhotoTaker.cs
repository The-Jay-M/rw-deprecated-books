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
public class PhotoTaker : Singleton<PhotoTaker>
{
    public GameObject Photo;

    // The API to asynchronously capture photos from the forward camera.
    PhotoCapture photoCaptureObject = null;
    Resolution cameraResolution;

    // Render to texture or to file.
    public bool renderToTexture = true;
    public bool takePhotoOnStart = true;

    void Start()
    {
		// Fill in
    }

    // 1 Asynchronously create a PhotoCapture instance
    void OnPhotoCaptureCreated(PhotoCapture captureObject)
    {
		// Fill in
    }

    // 2 Start capture
    void OnStartPhotoCapture(PhotoCapture.PhotoCaptureResult result)
    {
		// Fill in
    }

    // 3 Capture to a file.
    void OnCapturedPhotoToDisk(PhotoCapture.PhotoCaptureResult result)
    {
		// Fill in
    }

    // 4 Capture photo to a texture.
    void OnCapturedPhotoToMemory(PhotoCapture.PhotoCaptureResult result, PhotoCaptureFrame photoCaptureFrame)
    {
		// Fill in
    }

    // 5 Cleanup code
    void OnStoppedPhotoMode(PhotoCapture.PhotoCaptureResult result)
    {
		// Fill in
    }

    // 6 provide a way for other behavior(s) to programmatically take a photo.
    public void TakePicture()
    {
		// Fill in
    }
}
