uniform int isShadow;//阴影绘制标志
uniform mat4 uMVPMatrix; //总变换矩阵
uniform mat4 uRotateMatrix;//旋转矩阵
uniform mat4 uMMatrix; //变换矩阵
uniform mat4 uMProjCameraMatrix; //投影、摄像机组合矩阵
uniform vec3 uLightLocation;	//光源位置
uniform vec3 uCamera;	//摄像机位置
attribute vec3 aPosition;  //顶点位置
attribute vec3 aNormal;    //顶点法向量
attribute vec4 aColor;    //顶点颜色
varying vec4 vColor;  //用于传递给片元着色器的变量
varying vec4 ambient;
varying vec4 diffuse;
varying vec4 specular; 
//定位光光照计算的方法
void pointLight(					//定位光光照计算的方法
	in vec3 normal,				//法向量
	inout vec4 ambient,			//环境光最终强度
	inout vec4 diffuse,				//散射光最终强度
	inout vec4 specular,			//镜面光最终强度
	in vec3 lightLocation,			//光源位置
	in vec4 lightAmbient,			//环境光强度
	in vec4 lightDiffuse,			//散射光强度
	in vec4 lightSpecular			//镜面光强度
)
{
	ambient=lightAmbient;			//直接得出环境光的最终强度  
  	vec3 normalTarget=aPosition+normal;	//计算变换后的法向量
  	vec3 newNormal=(uMMatrix*vec4(normalTarget,1)).xyz-(uMMatrix*vec4(aPosition,1)).xyz;
  	newNormal=normalize(newNormal); 	//对法向量规格化
  	//计算从表面点到摄像机的向量
  	vec3 eye= normalize(uCamera-(uMMatrix*vec4(aPosition,1)).xyz);  
  	//计算从表面点到光源位置的向量vp
  	vec3 vp= normalize(lightLocation-(uMMatrix*vec4(aPosition,1)).xyz);  
  	vp=normalize(vp);//格式化vp
  	vec3 halfVector=normalize(vp+eye);	//求视线与光线的半向量    
  	float shininess=50.0;				//粗糙度，越小越光滑
 	float nDotViewPosition=max(0.0,dot(newNormal,vp)); 	//求法向量与vp的点积与0的最大值
  	diffuse=lightDiffuse*nDotViewPosition;				//计算散射光的最终强度
  	float nDotViewHalfVector=dot(newNormal,halfVector);	//法线与半向量的点积 
  	float powerFactor=max(0.0,pow(nDotViewHalfVector,shininess)); 	//镜面反射光强度因子
  	specular=lightSpecular*powerFactor;    			//计算镜面光的最终强度
}

void main()     
{
	if(isShadow==1)
   	{
		vec4 t_Position=uRotateMatrix * vec4(aPosition.x,-1.99,aPosition.z,1);
		mat4 finalMarix=uMProjCameraMatrix * uMMatrix;
		gl_Position = finalMarix * vec4(t_Position.x,-1.99,t_Position.z,1);
   	}
   	else
   	{
		//vec4 t_Position=uRotateMatrix * vec4(aPosition,1);
		//mat4 finalMarix=uMProjCameraMatrix * uMMatrix * uRotateMatrix ;
	  	//gl_Position = finalMarix * vec4(aPosition,1); //根据总变换矩阵计算此次绘制此顶点位置
		gl_Position = uMVPMatrix * vec4(aPosition,1); //根据总变换矩阵计算此次绘制此顶点位置
		vColor = aColor;//将接收的颜色传递给片元着色器
   	}
   
   	pointLight(normalize(aNormal),ambient,diffuse,specular,uLightLocation,vec4(0.8,0.8,0.8,1.0),vec4(0.2,0.2,0.2,1.0),vec4(0.2,0.2,0.2,1.0));

}                      