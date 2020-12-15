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
using UnityEngine;
using UnityEngine.XR.WSA;
using UnityEngine.XR.WSA.Persistence;

public class PersistentObject : MonoBehaviour
{
    // Define the prefab type
    public string PrefabTag;

    // Use this for initialization
    void Start()
    {
        // Register this object as a saveable object.
        SaveManager.Instance.SaveEvent += SaveFunction;
    }

    void OnDestroy()
    {
        if (SaveManager.Instance != null)
        {
            SaveManager.Instance.SaveEvent -= SaveFunction;
        }
    }

    // Common save function for all the game prefabs.
    public void SaveFunction(object sender, EventArgs args)
    {
        PrefabState ps = new PrefabState();
        ps.prefabTag = PrefabTag;
        ps.position = gameObject.transform.position;
        ps.rotation = gameObject.transform.rotation;
        ps.id = SaveManager.Instance.Game.GetUniqueId();
        SaveManager.Instance.Game.SaveableObjects.Add(ps);

        // Save a spatial anchor, if possible.
        WorldAnchorStore store = SaveManager.Instance.Store;
        if (store != null)
        {
            Debug.Log("Begin saving World Anchor for " + gameObject.name);
            // Get an existing anchor or add a new one.
            WorldAnchor anchor = gameObject.GetComponent(typeof(WorldAnchor)) as WorldAnchor;
            if (anchor == null)
            {
                anchor = gameObject.AddComponent(typeof(WorldAnchor)) as WorldAnchor;
            }
            // Save this position to restore later.
            if (anchor != null && anchor.isLocated)
            {
                String storeId = SaveManager.Instance.Game.AppAnchorPrefix + ps.id;
                if (store.Delete(storeId))
                {
                    Debug.Log("Deleted old World Anchor for " + gameObject.name);
                }
                if (store.Save(storeId, anchor))
                {
                    Debug.Log("World Anchor Saved for " + gameObject.name);
                }
            }
            else
            {
                Debug.Log("Unable to save World Anchor for " + gameObject.name);
            }
        }

        Debug.Log(gameObject.name + " added to save game");
    }
}

