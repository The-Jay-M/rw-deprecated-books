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
using UnityEngine.AI;

namespace Razeware.ARBook
{
    [RequireComponent(typeof(NetworkTransform))]
    public class NetworkEnemy : NetworkBehaviour
    {
        public Transform target;
        Transform spawnTransform;
        NavMeshAgent agent;

        public float navigationUpdate;
        float navigationTime = 0;

        bool isKilled;
        public float deathDuration;
        float deathTime;

        public int scoreValue;

        public GameObject normalGO;
        public GameObject scaredGO;
        public GameObject deadGO;

        Collider enemyCollider;

        [SyncVar] 
        protected bool poweredUpPlayerExists;

        enum EnemyState
        {
            Hunting,
            Running,
            Dead,
            ReadyToRespawn
        }

        EnemyState state;

        // Use this for initialization
        void Start()
        {
            agent = GetComponent<NavMeshAgent>();
            enemyCollider = GetComponent<Collider>();
            GameObject spawnTransformGo = new GameObject("SpawnTransform");
            spawnTransform = spawnTransformGo.transform;
            spawnTransform.position = transform.position;
            navigationTime = navigationUpdate; //cause first frame to navigate
            state = EnemyState.Hunting;
            poweredUpPlayerExists = false;
            if (NetworkClient.active)
            {
                NetworkRobotGameManager.Instance.EventPoweredUpPlayerExists += ChangeScaredState;
                poweredUpPlayerExists = NetworkRobotGameManager.Instance.playerPoweredUp;
            }

            state = EnemyState.Hunting;
            ChangeScaredState(poweredUpPlayerExists);
        }

        //server has called us to say that a powered up player exists, or that none are powered
        void ChangeScaredState(bool poweredUpPlayerExists)
        {
            if (state == EnemyState.Hunting && poweredUpPlayerExists)
            {
                ChangeState(EnemyState.Running);
            }
            else if (state == EnemyState.Running && !poweredUpPlayerExists)
            {
                ChangeState(EnemyState.Hunting);
            }

            this.poweredUpPlayerExists = poweredUpPlayerExists;
        }

        void ChangeState(EnemyState newState)
        {
            if (newState != state)
            {
                switch (newState)
                {
                    case EnemyState.Hunting:
                        //change appearance
                        ChangeGODisplay(normalGO);
                        //target closest player
                        target = NetworkRobotGameManager.Instance.GetClosestPlayer(transform.position).transform;
                        break;
                    case EnemyState.Dead:
                        NetworkRobotGameManager.Instance.RpcPlayDeathSound();
                        //change appearance
                        ChangeGODisplay(deadGO);
                        //run back home
                        target = spawnTransform;
                        break;
                    case EnemyState.Running:
                        //change appearance
                        ChangeGODisplay(scaredGO);
                        //run back home
                        target = spawnTransform;
                        break;
                }

                navigationTime = navigationUpdate; //cause first frame to navigate
                state = newState;
                enemyCollider.enabled = (state != EnemyState.Dead);
            }
        }

        void ChangeGODisplay(GameObject go)
        {
            normalGO.SetActive(go == normalGO);
            scaredGO.SetActive(go == scaredGO);
            deadGO.SetActive(go == deadGO);
        }


        [ClientRpc]
        void RpcChangeScaredState(bool poweredUpPlayerExists)
        {
            ChangeScaredState(poweredUpPlayerExists);
        }

        [ClientRpc]
        void RpcChangeState(EnemyState newState)
        {
            ChangeState(newState);
        }

        [ClientRpc]
        void RpcFindNewTarget()
        {
            NetworkPlayerRobot potentialTarget = NetworkRobotGameManager.Instance.GetClosestPlayer(transform.position);
            if (potentialTarget != null)
            {
                target = potentialTarget.transform;
            }
        }


        // Update is called once per frame
        [ServerCallback]
        void Update()
        {
            if (target != null)
            {
                navigationTime += Time.deltaTime;
                if (navigationTime > navigationUpdate)
                {
                    if (state == EnemyState.Hunting)
                    {
                        //find next target
                        RpcFindNewTarget();
                    }

                    agent.destination = target.position;
                    navigationTime = 0;
                }

                CheckDeathUpdate();
            }
        }

        [Server]
        void CheckDeathUpdate()
        {
            if (state != EnemyState.Dead)
            {
                return;
            }

            deathTime += Time.deltaTime;

            Vector3 currentPos = new Vector3(transform.position.x, 0.0f, transform.position.z);
            Vector3 targetPos = new Vector3(spawnTransform.position.x, 0.0f, spawnTransform.position.z);
            float dist = Vector3.Distance(currentPos, targetPos);

            Debug.Log("Dist = " + dist);

            if (dist < 0.1f && deathTime > deathDuration)
            {
                RpcChangeState(EnemyState.Hunting);
                isKilled = false;

                RpcChangeScaredState(poweredUpPlayerExists);
                deathTime = 0.0f;
            }
        }

        [ServerCallback]
        void OnTriggerEnter(Collider collider)
        {
            if (collider.gameObject.tag == "Player")
            {
                //we collided with a player, check if they are powered up.
                NetworkPlayerRobot robot = collider.gameObject.GetComponent<NetworkPlayerRobot>();
                if (robot.poweredUp)
                {
                    Killed();
                    robot.score += scoreValue;
                }
                else
                {
                    if (state == EnemyState.Hunting)
                    {
                        robot.Killed();
                        //find next target
                        RpcFindNewTarget();
                    }
                }
            }
        }

        [Server]
        public void Killed()
        {
            //if 2 players touch the enemy the same frame, they will both generate the callback before the enemy get destroyed
            //but we want to destroy it only once.
            if (isKilled)
            {
                return;
            }

            isKilled = true;

            RpcChangeState(EnemyState.Dead);

        }
    }
}