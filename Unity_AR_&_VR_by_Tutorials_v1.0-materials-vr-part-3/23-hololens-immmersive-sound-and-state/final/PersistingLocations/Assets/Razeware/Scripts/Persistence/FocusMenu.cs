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

/**
 * Display a menu when there is a focus held on a target GameObject.
 */
public class FocusMenu : MonoBehaviour, IFocusable
{
    [Tooltip("Set the prefab to be shown.")]
    public GameObject Menu;
    [Tooltip("Set the offset position.")]
    public Vector3 Offset;

    public float ShowDuration = 1f;
    public float HideDuration = 5f;

    private bool haveFocus = false;
    private float timer = 0f;
    private GameObject menu;

    // Use this for initialization
    void Start()
    {
        menu = Instantiate(Menu, gameObject.transform);
        menu.transform.localPosition = Offset;
        ShowOrHideMenu(false);
    }

    // Update is called once per frame
    void Update()
    {
        timer += Time.deltaTime;

        if (haveFocus && timer > ShowDuration)
        {
            ShowOrHideMenu(true);
        }

        if (!haveFocus && timer > HideDuration)
        {
            ShowOrHideMenu(false);
        }
    }

    // Change if menu is visible
    public void ShowOrHideMenu(bool show)
    {
        if (menu && menu.active != show)
        {
            menu.active = show;
        }
    }

    // When user's gaze is on this GameObject
    public void OnFocusEnter()
    {
        timer = 0f;
        haveFocus = true;
    }

    // When user's gaze leaves this GameObject
    public void OnFocusExit()
    {
        timer = 0f;
        haveFocus = false;
    }
}