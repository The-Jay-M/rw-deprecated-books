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
using UnityEngine.AI;

/**
 * Manages lifecycle of 'hidden' items in the world:
 */
public class HiddenState : AbstractStateMachine
{
    public GameObject HiddenItemPrefab;
    public float SpawnRadiusToPlayer = 10f;

    private GameObject HiddenGameObject;
    private bool CanExit;
    private IEnumerator Timer;

    public void Start()
    {
        // 1. States
        GameState ready = new GameState("ready", EnterReady);
        GameState hidden = new GameState("hidden", EnterHidden);
        GameState found = new GameState("found", EnterFound);

        // 2. Transitions
        ready.AddTransition(new StateTransition(() => CanExit, hidden));
        // 3. IsTriggered
        hidden.AddTransition(new StateTransition(() => IsTriggered(), found));
        hidden.AddTransition(new StateTransition(() => CanExit, ready));
        found.AddTransition(new StateTransition(() => CanExit, ready));

        // 4. Start the state machine.
        SetCurrentState(ready);
        SetEnabled(true);
    }

    void StartExitTimer(int seconds)
    {
        if (Timer != null)
        {
            StopCoroutine(Timer);
        }
        Timer = WaitToExit(seconds);
        StartCoroutine(Timer);
    }

    IEnumerator WaitToExit(int seconds)
    {
        yield return new WaitForSeconds(seconds);
        CanExit = true;
    }

    void EnterReady()
    {
        Destroy(HiddenGameObject);
        CanExit = false;
        StartExitTimer(5);
    }

    void EnterHidden()
    {
        // 1
        CanExit = false;
        StartExitTimer(15);

        // 2
        Vector3 navPt;
        if (RandomNavPoint(gameObject.transform.position, SpawnRadiusToPlayer, out navPt))
        {
            GameObject SceneRoot = GameObject.FindObjectOfType<SceneRoot>().gameObject;
            HiddenGameObject = Instantiate(HiddenItemPrefab);
            HiddenGameObject.transform.position = navPt;
            HiddenGameObject.transform.parent = SceneRoot.transform;
        }
    }

    void EnterFound()
    {
        CanExit = false;
        StartExitTimer(5);
    }

    bool IsTriggered()
    {
        if (HiddenGameObject)
        {
            HiddenItem item = HiddenGameObject.GetComponent<HiddenItem>();
            if (item)
            {
                return item.IsEntered;
            }
        }
        return false;
    }

    // Try to find a point on the NavMesh, return true if found.
    public static bool RandomNavPoint(Vector3 origin, float distance, out Vector3 location)
    {
        int layermask = -1;
        Vector3 randomDirection = UnityEngine.Random.insideUnitSphere * distance;
        randomDirection += origin;

        NavMeshHit navHit;
        NavMesh.SamplePosition(randomDirection, out navHit, distance, layermask);
        location = navHit.position;
        return (navHit.distance < distance);
    }

}
