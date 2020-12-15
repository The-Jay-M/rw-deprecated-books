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

// This StateMachine will be monitored by both the AnimationController
// and also the TapToMove script to determine when busy with an action.
[RequireComponent(typeof(AudioSource))]
public class PetState : AbstractStateMachine
{
    [Tooltip("Supply prefab for edible item")]
    public GameObject Kibble;

    public enum ActionType { Sleep, Eat, Drink, Jump, Wave, Navigating, None }
    public ActionType CurrentAction { get; set; }

    public GameObject Target { get; set; }
    public bool CanExit { get; set; }

    void Start()
    {
        // 1. define the states
        GameState canMove = new GameState("canMove", EnterCanMove);
        GameState action = new GameState("action", EnterAction);
        GameState holdAction = new GameState("holdAction", EnterHold);
        GameState releaseAction = new GameState("releaseAction", EnterRelease);

        // 2. add transitions
        canMove.AddTransition(new StateTransition(() => IsAtTarget(), action));

        action.AddTransition(new StateTransition(() => CanExit && CanHold(), holdAction));
        action.AddTransition(new StateTransition(() => CanExit && !CanHold(), canMove));

        holdAction.AddTransition(new StateTransition(() => CanExit, releaseAction));

        releaseAction.AddTransition(new StateTransition(() => CanExit, canMove));

        // 3. set the first state and action
        CurrentState = canMove;
        CurrentAction = ActionType.Navigating;
    }

    bool IsAtTarget()
    {
        // 1.
        if (Target && Vector3.Distance(Target.transform.position, gameObject.transform.position) < 0.2f)
        {
            return true;
        }
        return false;
    }

    bool CanHold()
    {
        // 1.
        if (CurrentAction == ActionType.Sleep)
        {
            return true;
        }
        return false;
    }

    void EnterCanMove()
    {
        // 1
        Target = null;
        CurrentAction = ActionType.Navigating;
        CanExit = false;
    }

    void EnterAction()
    {
        // 1.
        if (Target.GetComponent<TargetObject>().Target == TargetObject.TargetType.Bed)
        {
            CurrentAction = ActionType.Sleep;
            StartCoroutine(ExitAfterTime(3.6f));
        }
        // 2.
        if (Target.GetComponent<TargetObject>().Target == TargetObject.TargetType.Food)
        {
            float animTime = 7.7f;
            CurrentAction = ActionType.Eat;
            StartCoroutine(ExitAfterTime(animTime));

            GameObject hand = GameObject.Find("Hand.R");
            GameObject kibble = Instantiate(Kibble);
            if (hand && kibble)
            {
                kibble.transform.SetParent(hand.transform);
                kibble.transform.localPosition = new Vector3(0, 0, 0);
                Destroy(kibble, animTime / 2);
            }
        }
        // 3.
        if (Target.GetComponent<TargetObject>().Target == TargetObject.TargetType.Water)
        {
            CurrentAction = ActionType.Drink;
            StartCoroutine(ExitAfterTime(7.7f));
        }
        // 4.
        if (Target.GetComponent<TargetObject>().Target == TargetObject.TargetType.Points)
        {
            Destroy(Target, 0.5f);
            CurrentAction = ActionType.Jump;
            StartCoroutine(ExitAfterTime(1.9f));
        }
    }

    void EnterHold()
    {
        CanExit = false;
    }

    void EnterRelease()
    {
        CanExit = false;
        if (CurrentAction == ActionType.Sleep)
        {
            // 1.
            CurrentAction = ActionType.None;
            StartCoroutine(ExitAfterTime(8f));
        }
    }

    IEnumerator ExitAfterTime(float time)
    {
        yield return new WaitForSeconds(time);
        CanExit = true;
    }

    IEnumerator PlaySound(AudioClip sound, float delay)
    {
        yield return new WaitForSeconds(delay);
        GetComponent<AudioSource>().PlayOneShot(sound);
    }
}
