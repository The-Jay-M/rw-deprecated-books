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

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

[RequireComponent(typeof(ParticleSystem))]
public class RazewarePointParticleVisualizer : MonoBehaviour
{

    ParticleSystem ParticleSystem;
    ARPointCloud PointCloud;

    // Use this for initialization
    void Start()
    {
        ParticleSystem = GetComponent<ParticleSystem>();
        PointCloud = GetComponent<ARPointCloud>();
    }

    // Update is called once per frame
    void Update()
    {
        if (PointCloud != null && ParticleSystem != null)
        {
            List<Vector3> pointsInCloud = new List<Vector3>();
            PointCloud.GetPoints(pointsInCloud, Space.Self);

            ParticleSystem.Particle[] particles = new ParticleSystem.Particle[pointsInCloud.Count];
            int index = 0;
            foreach (Vector3 currentPoint in pointsInCloud)
            {
                particles[index].position = currentPoint;
                particles[index].startColor = new Color(1.0f, 1.0f, 1.0f);
                particles[index].startSize = 0.02f;
                index++;
            }
            ParticleSystem.SetParticles(particles, pointsInCloud.Count);
        }
    }
}
