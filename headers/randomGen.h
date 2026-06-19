#pragma once

#include <random>

namespace prng
{

inline std::mt19937_64 generate()
{
    thread_local std::random_device rd ;

    thread_local std::seed_seq seed_collection {rd(),rd(),rd(),rd(),rd(),rd(),rd(),rd(),rd(),rd()} ;

    return std::mt19937_64 { seed_collection } ;
}

inline thread_local std::mt19937_64 mt { generate() } ;

float getReal( float min , float max )
{
    return static_cast<float>(std::uniform_real_distribution<>{min,max}(mt)) ;
}
}
