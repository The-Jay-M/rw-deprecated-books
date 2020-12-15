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
using UnityEngine.Networking;

namespace Razeware.ARBook
{
    [RequireComponent(typeof(NetworkTransform))]
    public class NetworkCollectible : NetworkBehaviour
    {
        public int scoreValue = 1;
        public bool isPowerUp = false;
        
        protected bool isDestroyed = false;
        protected NetworkTransform netTransform;
        protected Collider collectibleCollider;

        void Start()
        {
            netTransform = GetComponent<NetworkTransform>();
            collectibleCollider = GetComponent<Collider>();
        }

        [ServerCallback]
        void OnTriggerEnter(Collider collider)
        {
            if (isDestroyed)
            {
                return;
            }

            //we collide so we dirty the NetworkTrasnform to sync it on clients.
            netTransform.SetDirtyBit(1);

            if (collider.gameObject.tag == "Player")
            {
                //we collided with the player, they have collected me .
                NetworkPlayerRobot robot = collider.gameObject.GetComponent<NetworkPlayerRobot>();
                robot.score += scoreValue;
                if (isPowerUp)
                {
                    robot.ServerPowerUp(true);
                }

                collectibleCollider.enabled = false;
                Collected();
            }
        }

        [Server]
        public void Collected()
        {
            //if 2 players touch the collectible the same frame, they will both generate the callback before the collectible get destroyed
            //but we want to destroy it only once.
            if (isDestroyed)
            {
                return;
            }

            isDestroyed = true;
            
            NetworkRobotGameManager.Instance.RpcPlayCollectedSound();

            if (isPowerUp)
            {
                NetworkRobotGameManager.Instance.numActivePowerPills--;
            }
            else
            {
                NetworkRobotGameManager.Instance.numActiveCollectibles--;
            }

            //destroy the collectible
            NetworkServer.Destroy(gameObject);
        }

    }
}