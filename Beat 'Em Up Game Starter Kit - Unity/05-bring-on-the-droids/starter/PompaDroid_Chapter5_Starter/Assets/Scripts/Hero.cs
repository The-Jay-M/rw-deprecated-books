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

public class Hero : Actor  {


  public float walkSpeed = 2;
  public float runSpeed = 5;

  bool isRunning;
  bool isMoving;
  float lastWalk;
  public bool canRun = true;
  float tapAgainToRunTime = 0.2f;
  Vector3 lastWalkVector;

  Vector3 currentDir;
  bool isFacingLeft;

  bool isJumpLandAnim;
  bool isJumpingAnim;
  
  public InputHandler input;
  
  public float jumpForce = 1750;
  private float jumpDuration = 0.2f;
  private float lastJumpTime;

  bool isAttackingAnim;  
  float lastAttackTime;
  float attackLimit = 0.14f;
  
  public override void Update() {
    base.Update();

    isAttackingAnim = baseAnim.GetCurrentAnimatorStateInfo(0).IsName("attack1");
    isJumpLandAnim = baseAnim.GetCurrentAnimatorStateInfo(0).IsName("jump_land");
    isJumpingAnim = baseAnim.GetCurrentAnimatorStateInfo(0).IsName("jump_rise") ||
      baseAnim.GetCurrentAnimatorStateInfo(0).IsName("jump_fall");


    float h = input.GetHorizontalAxis ();
    float v = input.GetVerticalAxis ();
    bool jump = input.GetJumpButtonDown();
    bool attack = input.GetAttackButtonDown();

    currentDir = new Vector3(h, 0, v);
    currentDir.Normalize();

    if (!isAttackingAnim) {
      if ((v == 0 && h == 0)) {
        Stop ();
        isMoving = false;
      } else if (!isMoving && (v != 0 || h != 0)) {
        isMoving = true;
        float dotProduct = Vector3.Dot (currentDir, lastWalkVector);
        if (canRun && Time.time < lastWalk + tapAgainToRunTime && dotProduct > 0) {
          Run ();
        } else {
          Walk ();
          if (h != 0) {
            lastWalkVector = currentDir;
            lastWalk = Time.time;
          }
        } 
      }
    }


    if (jump && !isJumpLandAnim && !isAttackingAnim &&
    (isGrounded || (isJumpingAnim && Time.time < lastJumpTime +
    jumpDuration)) ) {
      Jump(currentDir);
    }

    if (attack && Time.time >= lastAttackTime + attackLimit) {
      lastAttackTime = Time.time;
      Attack(); 
    }
  }

  public void Stop() {
    speed = 0;
    baseAnim.SetFloat("Speed", speed);
    isRunning = false;
    baseAnim.SetBool("IsRunning", isRunning);
  }

  public void Walk() {
    speed = walkSpeed;
    baseAnim.SetFloat("Speed", speed);
    isRunning = false;
    baseAnim.SetBool("IsRunning", isRunning);
  }


  void FixedUpdate() {
    Vector3 moveVector = currentDir * speed;
    if(isGrounded && !isAttackingAnim){
      body.MovePosition (transform.position + moveVector * Time.fixedDeltaTime);
      baseAnim.SetFloat ("Speed", moveVector.magnitude);
    }
    
    if (moveVector != Vector3.zero) {
      if (moveVector.x != 0) {
        isFacingLeft = moveVector.x < 0;
      }
      FlipSprite (isFacingLeft);
    }
  }


  public void Run() {
    speed = runSpeed;
    isRunning = true;
    baseAnim.SetBool("IsRunning", isRunning);
    baseAnim.SetFloat("Speed", speed);
  }

  void Jump(Vector3 direction) {
    if (!isJumpingAnim) {
      baseAnim.SetTrigger ("Jump");
      lastJumpTime = Time.time;
    
      Vector3 horizontalVector = new Vector3(direction.x, 0, direction.z) * speed * 40;
      body.AddForce(horizontalVector,ForceMode.Force);
    }

    Vector3 verticalVector = Vector3.up * jumpForce * Time.deltaTime;
    body.AddForce(verticalVector,ForceMode.Force);
  }
  
  protected override void DidLand()
  {
    base.DidLand();
    Walk(); 
  }

  public override void Attack() {
    baseAnim.SetInteger("EvaluatedChain", 0);
    baseAnim.SetInteger("CurrentChain", 1);
  }

  public void DidChain(int chain) {
    baseAnim.SetInteger("EvaluatedChain", 1);
  }

}
