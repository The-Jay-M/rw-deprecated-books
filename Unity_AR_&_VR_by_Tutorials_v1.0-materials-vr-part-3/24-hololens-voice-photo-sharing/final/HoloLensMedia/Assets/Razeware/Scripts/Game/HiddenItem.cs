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

[RequireComponent(typeof(BoxCollider))]
public class HiddenItem : MonoBehaviour {

    public bool IsEntered = false;
    public Material SonarPulseMat;
    public AudioClip PulseSound;
    public AudioClip CoinSound;
    public GameObject Coin;
    public GameObject Hole;

    private float Radius = 0f;
    private float MaxRadius = 1f;
    private float MinRadius = 0.25f;

    private float Interval = 0.05f;
    private float NextTime = 0f;
    private Animator animator;
	
    void Start()
    {
        animator = Hole.GetComponent<Animator>();
        animator.SetBool("IsOpen", false);
        SetupShader();
    }

	void Update () {
        Radius += Time.deltaTime;
        if (Time.time > NextTime)
        {
            NextTime = Time.time + Interval;

            // 1. Update the shader.
            UpdateShader();

            // 2. Restart ping when exceed a radius.
            if (Radius > MaxRadius)
            {
                Radius = MinRadius;
                PlaySound(PulseSound);
            }
        }
    }

    void OnTriggerEnter(Collider other)
    {
        IsEntered = true;
        animator.SetBool("IsOpen", true);

        StartCoroutine(CoinJump());
    }

    void PlaySound(AudioClip clip)
    {
        AudioSource source = GetComponent<AudioSource>();
        if (source && clip)
        {
            source.PlayOneShot(clip);
        }
    }

    void SetupShader()
    {
        SonarPulseMat.SetVector("_Center", transform.position);
        SonarPulseMat.SetInt("_UseWireframe", 0);
        SonarPulseMat.SetFloat("_PulseWidth", 0.1f);
    }

    void UpdateShader()
    {
        if (SonarPulseMat)
        {
            float Intensity = Mathf.Max(1.0f - Radius / 2f, 0.0f);
            SonarPulseMat.SetFloat("_Radius", Radius);
            SonarPulseMat.SetVector("_PulseColor", new Vector4(Intensity, Intensity, Intensity, -1));
        }
    }

    IEnumerator CoinJump()
    {
        float delay = 1;
        yield return new WaitForSeconds(delay);
        Destroy(Coin, delay);
        PlaySound(CoinSound);
        while (Coin)
        {
            Vector3 position = Coin.transform.position;
            position.y = position.y + Time.deltaTime;
            Coin.transform.position = position;
            yield return null;
        }
    }
}
