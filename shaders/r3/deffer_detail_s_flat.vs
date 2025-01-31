#include "common.h"

uniform float4 		consts; // {1/quant,1/quant,diffusescale,ambient}
 
/// uniform float4x4 array[1000];

uniform float2x4 array[2000];


float4x4 ComputeRotationMatrix(float2x4 data)
{
    float _sh = sin(data[0].x); 
	float _ch = cos(data[0].x);
    float _sp = sin(data[0].y); 
	float _cp = cos(data[0].y);
    float _sb = sin(data[0].z);
	float _cb = cos(data[0].z);
   
	float _cc = _ch*_cb;
	float _cs = _ch*_sb;
	float _sc = _sh*_cb;
	float _ss = _sh*_sb;

	float _11 = _cc - _sp * _ss;
	float _12 = -_cp * _sb;
	float _13 = _sp * _cs + _sc;
 
	float _21 =  _sp * _sc + _cs;
	float _22 =  _cp * _cb;
	float _23 =  _ss - _sp * _cc;
 
	float _31 = -_cp * _sh;
	float _32 = _sp;
	float _33 = _cp * _ch; 

	float Scale = data[0].w;

    // Формирование матрицы
    return float4x4(
		_11 * Scale, _21 * Scale, _31 * Scale, data[1].x,
		_12 * Scale, _22 * Scale, _32 * Scale, data[1].y,
		_13 * Scale, _23 * Scale, _33 * Scale, data[1].z,
		1.0f, 1.0f, 1.0f, data[1].w
    );
}


v2p_flat 	main (v_detail v)
{
	v2p_flat 		O;

	// index
	int 	i 	= v.misc.w;

	float4x4 array_data = ComputeRotationMatrix(array[i]);

	float4  m0 	= array_data[0];
	float4  m1 	= array_data[1];
	float4  m2 	= array_data[2];
	float4  c0 	= array_data[3];

	// float4  m0 	= array[i][0];
	// float4  m1 	= array[i][1];
	// float4  m2 	= array[i][2];
	// float4  c0 	= array[i][3];

	// Transform pos to world coords
	float4 	pos;
 	pos.x 		= dot	(m0, v.pos);
 	pos.y 		= dot	(m1, v.pos);
 	pos.z 		= dot	(m2, v.pos);
	pos.w 		= 1;

	// Normal in world coords
	float3 	norm;	
		norm.x 	= pos.x - m0.w	;
		norm.y 	= pos.y - m1.w	+ .75f;	// avoid zero
		norm.z	= pos.z - m2.w	;

	// Final out
	float4	Pp 	= mul		(m_WVP,	pos				);
	O.hpos 		= Pp;
	O.N 		= mul		(m_WV,  normalize(norm)	);
	
	float3	Pe	= mul		(m_WV,  pos				);
	O.tcdh 		= float4	((v.misc * consts).xyyy	);

	O.position	= float4	(Pe, 		c0.w		);

	return O;
}
FXVS;
