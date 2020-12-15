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
        agent = gameObject.GetComponent<NavMeshAgent>();
        lineRenderer = gameObject.GetComponent<LineRenderer>();
        lineRenderer.positionCount = 0;
    }

    public void Start()
    { 
        if (PetKeywordRecognizer.Instance != null)
        {
            PetKeywordRecognizer.Instance.GoThereEvent += GoThere;
        }
    }

    public void OnDestroy()
    {
        if (PetKeywordRecognizer.Instance != null)
        {
            PetKeywordRecognizer.Instance.GoThereEvent -= GoThere;
        }
    }

    public void GoThere(bool there)
    {
        Transform cameraTransform = CameraCache.Main.transform;
        Ray ray;
        if (there)
        {
            ray = new Ray(cameraTransform.position, cameraTransform.forward);
        } else
        {
            Vector3 origin = cameraTransform.position + cameraTransform.forward * 0.25f;
            Vector3 direction = Vector3.down;
            ray = new Ray(origin, direction);
        }
        SetDestination(ray);
    }

    public void SetDestination(Ray ray)
    {
        if (agent.isActiveAndEnabled)
        {
            if (Physics.Raycast(ray.origin, ray.direction, out hitInfo, maxDistance))
            {
                if (agent.isOnNavMesh)
                {
                    agent.destination = hitInfo.point;
                }
                else
                {
                    agent.Warp(hitInfo.point);
                }
            }
        }
        CreatePath();
    }

    // 3 Handle air tapping to find Physics.Raycast hit for HoloLens.
    public void OnInputClicked(InputClickedEventData eventData)
    {
        // Don't intercept other events from IInputClickHandlers.
        if (eventData.selectedObject.GetComponent<IInputClickHandler>() != null) return;

        // 1.
        PetState state = GetComponent<PetState>();
        if (state.CurrentState.Name == "holdAction")
        {
            state.CanExit = true;
            eventData.Use();
            return;
        } else if (state.CurrentState.Name != "canMove")
        {
            eventData.Use();
            return;
        }

        // 2
        if (eventData.selectedObject.GetComponent<TargetObject>() != null)
        {
            TargetObject t = eventData.selectedObject.GetComponent<TargetObject>();
            state.Target = t.gameObject;
        }

        Transform cameraTransform = CameraCache.Main.transform;
        Ray ray = new Ray(cameraTransform.position, cameraTransform.forward);
        SetDestination(ray);

        eventData.Use();
    }

    // 4 Visualize the agents path with the line renderer.
    private void CreatePath()
    {
        NavMeshPath path = new NavMeshPath();
        NavMesh.CalculatePath(agent.transform.position, agent.destination, NavMesh.AllAreas, path);
        Vector3[] positions = path.corners;

        lineRenderer.positionCount = positions.Length;
        for (int i = 0; i < positions.Length; i++)
        {
            lineRenderer.SetPosition(i, positions[i]);
        }
    }

    // 5 Call when ready to use the NavAgent.
    public void SetEnabled(bool enable)
    {
        active = enable;

        // Enable or disable the NavMeshAgent component.
        if (active)
        {
            if (agent != null)
            {
                agent.enabled = true;
                InputManager.Instance.PushFallbackInputHandler(gameObject);
            }
        }
        else
        {
            if (agent != null)
            {
                agent.enabled = false;
            }
        }
    }
}