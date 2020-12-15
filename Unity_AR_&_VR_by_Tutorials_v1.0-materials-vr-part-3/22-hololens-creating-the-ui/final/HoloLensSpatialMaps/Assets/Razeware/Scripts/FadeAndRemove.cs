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
using UnityEngine;

public class FadeAndRemove : MonoBehaviour
{
    [Tooltip("Seconds before the text will begin to fade.")]
    public float DelayBeforeFade = 3f;
    [Tooltip("Seconds over which the text will fade out.")]
    public float FadeTime = 5f;

    private float timer = 0;

    void Start()
    {
        // 1. fade via a coroutine + destroy with a delay.
        Destroy(gameObject, DelayBeforeFade + FadeTime);
        // 2. start a coroutine.
        StartCoroutine(Fade());
    }

    // 2.  Define the IEnumerator coroutine.
    IEnumerator Fade()
    {
        while (timer < DelayBeforeFade)
        {
            timer += Time.deltaTime;
            // 3. Pause here to carry on next frame.
            yield return null;
        }

        CanvasGroup group = GetComponent<CanvasGroup>();
        while (group.alpha > 0)
        {
            group.alpha -= Time.deltaTime / FadeTime;
            // 3. Pause here to carry on next frame.
            yield return null;
        }
    }
}