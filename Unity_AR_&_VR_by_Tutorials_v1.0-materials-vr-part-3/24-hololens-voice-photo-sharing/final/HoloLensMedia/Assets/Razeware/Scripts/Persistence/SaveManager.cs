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

using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml.Serialization;
using System.IO;
using UnityEngine;
using UnityEngine.XR.WSA.Persistence;
using HoloToolkit.Unity;

public class SaveManager : Singleton<SaveManager>
{
    public List<GameObject> SaveablePrefabs;

    // All active saveable objects will exist here.
    private GameObject SceneRoot;

    // Any saveable GameObject provides a SaveDelegate callback function
    public delegate void SaveDelegate(object sender, EventArgs args);
    public event SaveDelegate SaveEvent;

    // A save game and an anchor store are where data is persisted.
    public SaveGame Game;
    public WorldAnchorStore Store = null;
    private string saveGameName;

    // Use this for initialization
    void Awake()
    {
        saveGameName = Application.persistentDataPath + "/gamesave.save";
        Debug.Log("Will save to " + saveGameName);

        SceneRoot = GameObject.FindObjectOfType<SceneRoot>().gameObject;

        // Need to prepare the WorldAnchorStore
        WorldAnchorStore.GetAsync(StoreLoaded);
    }

    private void StoreLoaded(UnityEngine.XR.WSA.Persistence.WorldAnchorStore store)
    {
        this.Store = store;
    }

    // Update is called once per frame
    void Update()
    {
        // For testing in editor
        if (Input.GetKeyDown(KeyCode.P))
        {
            Save();
        }
        if (Input.GetKeyDown(KeyCode.L))
        {
            Load();
        }
        if (Input.GetKeyDown(KeyCode.N))
        {
            New();
        }
    }

    // Create a new game.
    public void New()
    {
        Game = new SaveGame();
        InstantiateState(false);
        Debug.Log("New Game");
    }

    // Save the game.
    public void Save()
    {
        // 1 Create empty save game data.
        Game = new SaveGame();

        // 2 Fire off event to have all objects add save data.
        if (SaveEvent != null)
            SaveEvent(null, null);

        // 3 Serialize
        XmlSerializer serializer = new XmlSerializer(typeof(SaveGame));

        File.Delete(saveGameName);
        FileStream stream =
          new FileStream(saveGameName, FileMode.OpenOrCreate);

        serializer.Serialize(stream, Game);
        stream.Dispose();
        Debug.Log("Game Saved");
    }

    // Load the game.
    public void Load()
    {
        if (File.Exists(saveGameName))
        {
            // 1 - deserialize the save game information.
            XmlSerializer serializer = new XmlSerializer(typeof(SaveGame));
            FileStream stream = File.Open(saveGameName, FileMode.Open);
            Game = serializer.Deserialize(stream) as SaveGame;
            stream.Dispose();

            // 2 - any setup after loading data.
            InstantiateState(true);

            // 3 - restart the any objects
            foreach (Transform child in SceneRoot.transform)
            {
                GameObject go = child.gameObject;
                IActivatable activate = go.GetComponent(typeof(IActivatable)) as IActivatable;
                if (activate != null)
                {
                    activate.SetEnabled(true);
                }
            }
            Debug.Log("Game Loaded");
        }
    }

    // 1 Clear all from the SceneRoot.
    public void Cleanup()
    {
        foreach (Transform child in SceneRoot.transform)
        {
            GameObject.Destroy(child.gameObject);
        }
    }

    // After a save or load, instantiate the state.
    public void InstantiateState(bool restoreAnchors)
    {
        Cleanup();

        // Convert from PrefabState -> Prefabs.
        foreach (PrefabState p in Game.SaveableObjects)
        {
            GameObject prefab = null;
            foreach (GameObject go in SaveablePrefabs)
            {
                PersistentObject info = go.GetComponent<PersistentObject>();
                if (info)
                {
                    if (info.PrefabTag == p.prefabTag)
                    {
                        prefab = GameObject.Instantiate(go);
                        break;
                    }
                }
            }

            if (prefab)
            {
                prefab.transform.position = p.position;
                prefab.transform.rotation = p.rotation;

                // Try to restore a world anchor.
                if (restoreAnchors && Store != null)
                {
                    String storeId = Game.AppAnchorPrefix + p.id;
                    bool haveAnchor = this.Store.Load(storeId, prefab);
                    if (haveAnchor)
                    {
                        Debug.Log("Added previous spatial anchor");
                    }
                }

                // Set the parent, keeping the location, after restoring the WorldAnchor.
                prefab.transform.SetParent(SceneRoot.transform, true);
                Debug.Log(prefab.name + " restored to the scene.");
            }
        }
    }
}
