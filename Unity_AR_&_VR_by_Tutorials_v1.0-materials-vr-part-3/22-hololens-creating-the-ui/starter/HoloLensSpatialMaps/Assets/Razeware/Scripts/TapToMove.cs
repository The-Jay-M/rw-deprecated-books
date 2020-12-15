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

using HoloToolkit.Unity;
using HoloToolkit.Unity.SpatialMapping;
using HoloToolkit.Unity.InputModule;
using UnityEngine.AI;
using UnityEngine;

[RequireComponent(typeof(UnityEngine.AI.NavMeshAgent))]
public class TapToMove : MonoBehaviour, IInputClickHandler, IActivatable
{
    [Tooltip("Distance from camera to keep the object while placing it.")]
    public float DefaultGazeDistance = 2.0f;

    private RaycastHit hitInfo = new RaycastHit();
    private NavMeshAgent agent;
    private LineRenderer lineRenderer;
    private const float maxDistance = 30f;

    private bool active = false;

    // 1 Wire in the NavMeshAgent, and LineRenderer for the path visualization
    public void Awake()
    {
        // Fill in
    }

    // 2 Set a destination
    public void SetDestination(Ray ray)
    {
        // Fill in
    }

    // 3 Handle air tapping to find Physics.Raycast hit for HoloLens.
    public void OnInputClicked(InputClickedEventData eventData)
    {
        // Fill in
    }

    // 4 Visualize the agents path with the line renderer.
    private void CreatePath()
    {
    }

    // 5 Call when ready to use the NavAgent.
    public void SetEnabled(bool enable)
    {
    }
}
