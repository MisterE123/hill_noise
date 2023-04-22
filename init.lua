hill_noise = {}

local pi = math.pi
local golden = (math.sqrt(5)+1)/2
local math_floor = math.floor

-- Precompute sine values for angles between 0 and 2 * pi with 1024 elements
local sine_table = {}
for i = 0, 1023 do
    sine_table[i] = math.sin(2 * pi * i / 1024)
end

-- Function to normalize any input angle to the range 0 to 2 * pi
local function normalize_angle(angle)
    local two_pi = 2 * pi
    return angle - two_pi * math.floor(angle / two_pi)
end

-- Function to find the nearest table index for a given angle
local function find_nearest_index(angle)
    return math.floor(normalize_angle(angle) * 1024 / (2 * pi)) % 1024
end

-- Sine function using precomputed table and linear interpolation
local function sin(angle)
    local index = find_nearest_index(angle)
    local alpha = normalize_angle(angle) * 1024 / (2 * pi) - index

    local index_next = (index + 1) % 1024

    return sine_table[index] * (1 - alpha) + sine_table[index_next] * alpha
end

-- Cosine function using precomputed sine table and linear interpolation
local function cos(angle)
    return sin(angle + pi / 2)
end


function hill_noise.get_random_sizes(qty,seed)
    math.randomseed(seed)
    local waves = {}
    for i=1,qty do
        table.insert(waves,math.random())
    end
    return waves
end


hill_noise.newNoise = function(sizes,seed) -- sizes is a list of wavelengths between 0 and 1
                                      -- seed is used for random offsets and for sizes if sizes is a number
    local numwaves = #sizes
    math.randomseed(seed or math.random()) 

    local noise = {}
    
    local waves = {}

    -- sizes is a list of wavelengths between 0 and 1, lets set their domain to be between 0 and 2pi
    for i,size in ipairs(sizes) do
        sizes[i] = size*2*pi
    end

    local offsets = {}
    local rotations = {}
    local sigma = 0 -- redistribution
    for i=1,#sizes+2 do -- extra offsets for extra dims
        table.insert(offsets,math.random()*2*pi)
        if i <= #sizes then
            sigma = sigma + (sizes[i]/2)*(sizes[i]/2)
        end
    end



    noise.calculate = function(pos,dims,scale)
        scale = scale or 1
        local x,y,z
        if pos.x then x=pos.x/scale end
        if pos.y then y=pos.y/scale end
        if pos.z then z=pos.z/scale end


        local val = 0
        for i,wavelength in ipairs(sizes) do
            local noiseadd = 0
            if dims == 2 then
                local rot = (i*golden % 1)*2*pi
                u = x*cos(rot)-y*sin(rot)
                v = -x*sin(rot)-y*cos(rot)
                noiseadd = wavelength*0.5*(sin(offsets[i]+u/wavelength)+sin(offsets[i+1]+v/wavelength))
            end
            if dims == 3 then
                local rot1 = (i*golden % 1)*2*pi
                local rot2 = ((i+1)*golden % 1)*2*pi
                local sin1 = sin(rot1)
                local cos1 = cos(rot1)
                local sin2 = sin(rot2)
                local cos2 = cos(rot2)
                local u = x*cos1 - y*sin1
                local v = (x*sin1 + y*cos1)*cos2 - z*sin2
                local w = (x*sin1 + y*cos1)*sin2 + z*cos2
                noiseadd = wavelength*0.5*(sin(offsets[i] + u/wavelength) + sin(offsets[i+1] + v/wavelength) + sin(offsets[i+2] + w/wavelength))                
            end
            val = val + noiseadd
        end
        val = val/(2*sigma)
        local control = .5
        if val < 0 then control = -.5 end
        return (control*math.sqrt(1-math.exp(-2/pi*val*val)) +.5)
    end
    
    
    return noise

end
