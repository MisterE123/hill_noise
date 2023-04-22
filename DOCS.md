A noise algorithm by Bruce Hill, based of interfering sine waves, modified and adapted by MisterE

The noise produces values solidly bewteen 0 and 1, with the maximum and minimum value influenced by the maximum size passed in `sizes`, a size of 1 producing the maximum value.

###Creating Noise:
You can create a new noise with:
```lua
hill_noise.newNoise(sizes:table,seed:number)

```
    sizes: a table of wavelength values between 0 and 1. (which will be mapped to 0-2pi) The number of elements in the table determines the number of "octaves" in the noise. The value of each element, between 0 and 1, determines the scale of each octave. 

    seed: the seed used for random offsets of each scale. Ideally, pass the world seed plus some constant.


You can get a table of random sizes with: 

```lua
hill_noise.get_random_sizes(qty:number,seed:number)
```

    qty: the number of octaves. More octaves are more computationally intense. Use at least 3 to get anything like random noise.

    seed: same as above, this time used for random wavelengths between 0 and 1

###Using noise:

You have created a new noise with:
```lua
mynoise = hill_noise.newNoise(sizes,seed)
```

you can retrieve a noise value with:

```lua
mynoise.calculate(pos:table,dims:number,scale:number)
```
    pos: if `dims == 2` then `pos = {x=x_pos,y=y_pos}` if `dims == 3` then `pos = {x=x_pos,y=y_pos,z=z_pos}`

    dims: number of dimensions, either 2 or 3

    scale: number to divide all coordinates by to scale the noise up. A value of 1 is too small. A value of 20 might be good. You can also get custom scales on each axis by first dividing pos coordinates by a custom number (in which case you might pass 1 here)




