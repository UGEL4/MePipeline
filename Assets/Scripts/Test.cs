using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    private RenderTexture rt;

    public Transform cubeTrans;
    public Mesh cubeMesh;
    public Material cubeMaterial;

    void Start()
    {
        rt = new RenderTexture(Screen.width, Screen.height, 24);
    }

    // Will be called from camera after regular rendering is done.
    public void OnPostRender()
    {
        Camera cam = Camera.current;
        Graphics.SetRenderTarget(rt);
        GL.Clear(true, true, Color.grey);
        //start drawcall
        cubeMaterial.color = new Color(0, 0, 1, 1);
        cubeMaterial.SetPass(0);
        Graphics.DrawMeshNow(cubeMesh, cubeTrans.localToWorldMatrix);
        DrawSkyBox(cam);
        //end drawcall
        Graphics.Blit(rt, cam.targetTexture);
    }

    private static Mesh mMesh;
    public static Mesh fullScreenMush
    {
        get
        {
            if (mMesh != null)
            {
                return mMesh;
            }
            mMesh = new Mesh();
            mMesh.vertices = new Vector3[]
            {
                new Vector3(-1, -1, 0),
                new Vector3(-1, 1, 0),
                new Vector3(1, 1, 0),
                new Vector3(1, -1, 0)
            };
            mMesh.uv = new Vector2[]{
                new Vector2(0, 1),
                new Vector2(0, 0),
                new Vector2(1, 0),
                new Vector2(1, 1)
            };
            mMesh.SetIndices(new int[]{0, 1, 2, 3}, MeshTopology.Quads, 0);

            return mMesh;
        }
    }

    private static Vector4[] corners = new Vector4[4];

    public Material skyBoxMaterial;
    public void DrawSkyBox(Camera cam)
    {
        corners[0] = cam.ViewportToWorldPoint(new Vector3(0, 0, cam.farClipPlane));
        corners[1] = cam.ViewportToWorldPoint(new Vector3(1, 0, cam.farClipPlane));
        corners[2] = cam.ViewportToWorldPoint(new Vector3(0, 1, cam.farClipPlane));
        corners[3] = cam.ViewportToWorldPoint(new Vector3(1, 1, cam.farClipPlane));

        skyBoxMaterial.SetVectorArray("_Corner", corners);
        skyBoxMaterial.SetPass(0);
        Graphics.DrawMeshNow(fullScreenMush, Matrix4x4.identity);
    }
}
