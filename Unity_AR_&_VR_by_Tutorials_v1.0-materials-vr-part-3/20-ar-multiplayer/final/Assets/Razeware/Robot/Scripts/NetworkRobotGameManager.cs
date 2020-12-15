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
using Razeware.NetworkLobby;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine.AI;

namespace Razeware.ARBook
{
    public class NetworkRobotGameManager : NetworkBehaviour
    {
        public static List<NetworkPlayerRobot> Robots = new List<NetworkPlayerRobot>();
        public static NetworkRobotGameManager Instance;

        public Transform contentTransform;
        public float contentMaxDimension;

        public GameObject uiScoreZone;
        public Font uiScoreFont;
        public Text winnerDisplay;

        [Header("Gameplay")] public GameObject[] enemyPrefabs;
        public GameObject[] collectiblePrefabs; // index 0 = normal, index 1 = powerup

        public Vector2 collectibleSpawnMinPosition;
        public Vector2 collectibleSpawnMaxPosition;


        public List<Transform> spawnPositions;
        public List<Transform> enemySpawnPositions;

        public AudioClip gameBackgroundMusic;
        public AudioClip startRoundSound;
        public AudioClip collectedSound;
        public AudioClip powerUpSound;
        public AudioClip powerDownSound;
        public AudioClip deathSound;

        public delegate void PoweredUpPlayerExistsDelegate(bool exists);

        [SyncEvent] public event PoweredUpPlayerExistsDelegate EventPoweredUpPlayerExists;

        [SyncVar] public bool playerPoweredUp;

        [SyncVar] public int numActiveCollectibles;

        [SyncVar] public int numActivePowerPills;

        [Space] 
        
        protected bool spawningCollectibles = true;
        protected bool spawningPowerPills = true;
        
        protected bool running = false;
        protected int regularPillsBatch = 9;
        protected AudioSource audioSource;
        

        void Awake()
        {
            Instance = this;
            playerPoweredUp = false;
            winnerDisplay.enabled = false;
            audioSource = GetComponent<AudioSource>();
        }

        void Start()
        {
            if (isServer)
            {
                StartCoroutine(EnemiesCoroutine());
                StartCoroutine(CollectiblesCoroutine());
                StartCoroutine(PowerPillCoroutine());
            }

            foreach (var robot in Robots)
            {
                robot.Init();
            }
        }

        public Vector3 GetPossibleSpawnPosition()
        {
            Vector3 retVal = new Vector3(0.0f, 1.0f, 0.0f);
            if (spawnPositions.Count > 0)
            {
                Transform chosen = spawnPositions.FindLast(t => t != null);
                if (chosen != null)
                {
                    spawnPositions.Remove(chosen);
                    retVal = chosen.position;
                }
            }

            return retVal;
        }

        public Vector3 GetPossibleEnemySpawnPosition()
        {
            Vector3 retVal = new Vector3(0.0f, 1.0f, 0.0f);
            if (enemySpawnPositions.Count > 0)
            {
                Transform chosen = enemySpawnPositions.FindLast(t => t != null);
                if (chosen != null)
                {
                    enemySpawnPositions.Remove(chosen);
                    retVal = chosen.position;
                }
            }

            return retVal;
        }


        public NetworkPlayerRobot GetClosestPlayer(Vector3 from)
        {
            NetworkPlayerRobot result = null;
            float closestDist = float.MaxValue;

            foreach (NetworkPlayerRobot npr in Robots)
            {
                float playerDist = Vector3.Distance(from, npr.transform.position);
                if (playerDist < closestDist)
                {
                    closestDist = playerDist;
                    result = npr;
                }
            }

            return result;
        }

        [ServerCallback]
        void Update()
        {
            if (Robots.Count > 1) //our game start check (more than one player has started)
            {
                running = true;
            }

            if (!running) //only check for game end after it has started
            {
                return;
            }

            int numLivePlayers = 0;
            NetworkPlayerRobot oneLivePlayer = null;
            for (int i = 0; i < Robots.Count; ++i)
            {
                if (Robots[i].lifeCount > 0)
                {
                    numLivePlayers++;
                    oneLivePlayer = Robots[i];
                }
            }

            if (numLivePlayers == 1)
            {
                RpcDisplayWinner(oneLivePlayer.playerName);

                StartCoroutine(ReturnToLobby());
                return;
            }

            if (!spawningCollectibles && numActiveCollectibles == 0)
            {
                spawningCollectibles = true;
                StartCoroutine(CollectiblesCoroutine());
            }

            if (!spawningPowerPills && numActivePowerPills == 0)
            {
                spawningPowerPills = true;
                StartCoroutine(PowerPillCoroutine());
            }
        }

        [ClientRpc]
        void RpcDisplayWinner(string playerName)
        {
            winnerDisplay.enabled = true;
            winnerDisplay.text = playerName + " wins!";
        }

        [ClientRpc]
        public void RpcPlayDeathSound()
        {
            audioSource.PlayOneShot(deathSound);
        }
        
        [ClientRpc]
        public void RpcPlayPowerUpSound()
        {
            audioSource.PlayOneShot(powerUpSound);
        }

        [ClientRpc]
        public void RpcPlayPowerDownSound()
        {
            audioSource.PlayOneShot(powerDownSound);
        }
        
        [ClientRpc]
        public void RpcPlayCollectedSound()
        {
            audioSource.PlayOneShot(collectedSound);
        }


        public override void OnStartClient()
        {
            base.OnStartClient();

            PlaneChooser.Instance.PlaceOnSelectedPlane(contentTransform, contentMaxDimension);

            foreach (GameObject obj in enemyPrefabs)
            {
                ClientScene.RegisterPrefab(obj);
            }

            foreach (GameObject obj in collectiblePrefabs)
            {
                ClientScene.RegisterPrefab(obj);
            }

            audioSource.clip = gameBackgroundMusic;
            audioSource.loop = true;
            audioSource.spatialBlend = 0.0f; //make it 2d
            audioSource.Play();
            audioSource.PlayOneShot(startRoundSound);
        }

        IEnumerator ReturnToLobby()
        {
            running = false;
            yield return new WaitForSeconds(4.0f);
            LobbyManager.s_Singleton.ServerReturnToLobby();
        }

        IEnumerator CollectiblesCoroutine()
        {
            const float MIN_TIME = 3.0f;
            const float MAX_TIME = 5.0f;

            yield return new WaitForSeconds(Random.Range(MIN_TIME, MAX_TIME));

            for (int i = 0; i < regularPillsBatch; i++)
            {
                yield return new WaitForSeconds(0.1f);
                SpawnCollectible(collectiblePrefabs[0]);
            }

            spawningCollectibles = false;
        }

        IEnumerator PowerPillCoroutine()
        {
            const float MIN_TIME = 15.0f;
            const float MAX_TIME = 20.0f;

            yield return new WaitForSeconds(Random.Range(MIN_TIME, MAX_TIME));
            
            SpawnCollectible(collectiblePrefabs[1], true);
            spawningPowerPills = false;
        }
        
        void SpawnCollectible(GameObject prefab, bool isPowerUp = false)
        {
            bool positionFound = false;
            Vector3 position;
            NavMeshHit hit;

            do
            {
                float xpos = Mathf.Round(Random.Range(collectibleSpawnMinPosition.x, collectibleSpawnMaxPosition.x));
                float zpos = Mathf.Round(Random.Range(collectibleSpawnMinPosition.y, collectibleSpawnMaxPosition.y));

                if (Mathf.Abs(xpos) < 4.0f && Mathf.Abs(zpos) < 4.0f)
                {
                    continue;  //too close to center ghostbox
                }
                
                position = new Vector3(xpos, 0.0f, zpos);
                positionFound = NavMesh.SamplePosition(position, out hit, 0.1f, NavMesh.AllAreas);
                
            } while (!positionFound);

            position = new Vector3(hit.position.x, 0.3f, hit.position.z);
            GameObject go = Instantiate(prefab, position,
                Quaternion.Euler(Random.value * 360.0f, Random.value * 360.0f, Random.value * 360.0f)) as GameObject;
            NetworkServer.Spawn(go);
            if (isPowerUp)
            {
                numActivePowerPills++;
            }
            else
            {
                numActiveCollectibles++;
            }
        }

        IEnumerator EnemiesCoroutine()
        {
            const float MIN_TIME = 5.0f;
            const float MAX_TIME = 10.0f;

            yield return new WaitForSeconds(Random.Range(MIN_TIME, MAX_TIME));

            for (int i = 0; i < Robots.Count; i++)
            {
                Vector3 position = GetPossibleEnemySpawnPosition();

                GameObject go = Instantiate(enemyPrefabs[enemyPrefabs.Length - 1], position,
                    Quaternion.Euler(Random.value * 360.0f, Random.value * 360.0f,
                        Random.value * 360.0f)) as GameObject;

                NetworkEnemy enemy = go.GetComponent<NetworkEnemy>();
                NetworkPlayerRobot closest = GetClosestPlayer(position);
                enemy.target = closest.transform;

                NavMeshAgent agent = go.GetComponent<NavMeshAgent>();
                agent.speed = Random.Range(1.5f, 2.0f);
                agent.acceleration = agent.speed * 4.0f;

                NetworkServer.Spawn(go);
            }
        }


        [Server]
        public void CheckPowerUpInfo()
        {
            bool poweredUpPlayerExists = false;

            foreach (NetworkPlayerRobot nr in Robots)
            {
                poweredUpPlayerExists |= nr.poweredUp;
            }

            playerPoweredUp = poweredUpPlayerExists;
            EventPoweredUpPlayerExists.Invoke(poweredUpPlayerExists);

            foreach (NetworkPlayerRobot nr in Robots)
            {
                if (nr.poweredUp)
                {
                    nr.RpcPlayerPoweredGO();
                }
                else if (playerPoweredUp)
                {
                    nr.RpcPlayerScaredGO();
                }
                else
                {
                    nr.RpcPlayerNormalGO();
                }
            }
        }
    }
}
