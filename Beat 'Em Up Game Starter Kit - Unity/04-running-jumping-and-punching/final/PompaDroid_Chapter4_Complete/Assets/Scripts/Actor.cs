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

public class Actor : MonoBehaviour {


  public Animator baseAnim;
  public Rigidbody body;
  public SpriteRenderer shadowSprite;

  public float speed = 2;

  protected Vector3 frontVector;
  public bool isGrounded;

  public virtual void Update() {
    Vector3 shadowSpritePosition = shadowSprite.transform.position;
    shadowSpritePosition.y = 0;
    shadowSprite.transform.position = shadowSpritePosition;
  }

  protected  virtual void OnCollisionEnter(Collision collision) {
    if (collision.collider.name == "Floor") {
      isGrounded = true;
      baseAnim.SetBool("IsGrounded", isGrounded);
      DidLand();
    } 
  }

  protected virtual void OnCollisionExit(Collision collision) {
    if (collision.collider.name == "Floor") {
      isGrounded = false;
      baseAnim.SetBool("IsGrounded", isGrounded);
    }
  }

  protected virtual void DidLand()
  {
  }


  public void FlipSprite(bool isFacingLeft) {
    if (isFacingLeft) {
      frontVector = new Vector3(-1, 0, 0);
      transform.localScale = new Vector3(-1, 1, 1);
    } else {
      frontVector = new Vector3(1, 0, 0);
      transform.localScale = new Vector3(1, 1, 1);
    }
  }

  public virtual void Attack() {
    baseAnim.SetTrigger("Attack");
  }
}
