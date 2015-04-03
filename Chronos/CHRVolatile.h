//
//  CHRVolatile.h
//  Chronos
//
//  Created by Andrew Chun on 4/2/15.
//  Copyright (c) 2015 com.zero223. All rights reserved.
//

#ifndef Chronos_CHRVolatile_h
#define Chronos_CHRVolatile_h

typedef struct {
    volatile int32_t _running;
    volatile int64_t _invocations;
} CHRVolatile;

#endif
