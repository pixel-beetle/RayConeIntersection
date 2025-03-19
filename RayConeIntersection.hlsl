struct RayConeIntersection
{
    int Count;
    float NearT;
    float FarT;
};

RayConeIntersection DoRayConeIntersection(float3 rayOrigin, float3 rayDir, float coneHeight, float tanThetaSqr)
{
    RayConeIntersection result = (RayConeIntersection)0;
    const float EPSILON = 1e-5;
    
    // 联立圆锥和射线方程 求根
    float A = dot(rayDir.xy, rayDir.xy) - tanThetaSqr * rayDir.z * rayDir.z;
    float B = 2.0 * (dot(rayOrigin.xy, rayDir.xy) - tanThetaSqr * rayOrigin.z * rayDir.z);
    float C = dot(rayOrigin.xy, rayOrigin.xy) - tanThetaSqr * rayOrigin.z * rayOrigin.z;

    // 判别式
    float D = B * B - 4.0 * A * C;
    
    // 初始化 t 值
    float t0 = -1.0, t1 = -1.0;
    bool valid0 = false, valid1 = false;

    // 计算侧面交点
    valid0 = D >= 0.0;
    float sqrtD = valid0 ? sqrt(D) : 0.0;
    t0 = valid0 ? (-B - sqrtD) / (2.0 * A) : -1.0;
    t1 = valid0 ? (-B + sqrtD) / (2.0 * A) : -1.0;

    // 检查 z 范围是否在 [0, h] 内
    float z0 = rayOrigin.z + t0 * rayDir.z;
    float z1 = rayOrigin.z + t1 * rayDir.z;
    valid0 = (t0 >= 0.0) && (z0 >= 0.0 && z0 <= coneHeight);
    valid1 = (t1 >= 0.0) && (z1 >= 0.0 && z1 <= coneHeight);

    // 底面相交计算
    float tBottom = (abs(rayDir.z) > EPSILON) ? ((coneHeight - rayOrigin.z) / rayDir.z) : -1.0;
    bool hitBottom = tBottom >= 0.0;
    float2 pBottomXY = rayOrigin.xy + tBottom * rayDir.xy;
    hitBottom = hitBottom && (dot(pBottomXY, pBottomXY) <= (tanThetaSqr * coneHeight * coneHeight));

    // 收集所有有效 t 值
    float tValues[3] = {-1.0, -1.0, -1.0};
    int count = 0;
    tValues[count] = valid0 ? t0 : -1.0;
    count += valid0 ? 1 : 0;
    tValues[count] = valid1 ? t1 : -1.0;
    count += valid1 ? 1 : 0;
    tValues[count] = hitBottom ? tBottom : -1.0;
    count += hitBottom ? 1 : 0;

    // 如果没有交点，直接返回
    result.Count = count;
    if (count == 0)
        return result;

    // 排序 t
    float a = tValues[0], b = tValues[1], c = tValues[2];
    float minVal = min(min(a, b), c);
    float maxVal = max(max(a, b), c);
    float midVal = a + b + c - minVal - maxVal;

    // 设置结果
    result.NearT = (count == 1)
                       ? maxVal
                       : (minVal < 0.0 ? midVal : minVal);
    result.FarT = maxVal;
    return result;
}
