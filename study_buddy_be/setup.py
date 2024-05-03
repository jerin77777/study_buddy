from db_models import *

create_db()
car = """
<svg width="365" height="185">
    <!-- Top -->
      <rect x="70" y="10" width="220" height="130" fill="transparent" rx="150" stroke="crimson" stroke-width="10" />
    
    <!-- Body -->
      <rect x="10" y="70" width="340" height="80" fill="crimson" rx="30" />
      
    <g>
    <!-- Left line -->
      <line x1="145" y1="10" x2="145" y2="80" stroke="crimson" stroke-width="10"/>

    <!-- Right line -->
      <line x1="215" y1="10" x2="215" y2="80" stroke="crimson" stroke-width="10"/>
    </g>
  
    <g>
    <!-- Left bumper -->
      <rect x="0" y="110" width="40" height="20" fill="#999" rx="10" />
    
    <!-- Right bumper -->
      <rect x="325" y="110" width="40" height="20" fill="#999" rx="10" />
    </g>  
  
    <!-- Left wheel -->
    <g>
      <circle r="40px" fill="#222" stroke="white" stroke-width="7" cx="90" cy="140"/>    
      <circle r="15px" fill="#555" cx="90" cy="140"/>
    </g>
  
    <!-- Right wheel -->
    <g>
      <circle r="40px" fill="#222" stroke="white" stroke-width="7" cx="270" cy="140"/>
      <circle r="15px" fill="#555" cx="270" cy="140"/>
    </g>  

    <g>
    <!-- Gold light -->
      <circle r="15px" fill="gold" cx="340" cy="90"/>
      
    <!-- Orange light -->
      <circle r="10px" fill="orange" cx="15" cy="90"/>
    </g>  
</svg>
"""
ball = """
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--! Font Awesome Free 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. --><path d="M148.7 171.3L64.21 86.83c-28.39 32.16-48.9 71.38-58.3 114.8C19.41 205.4 33.34 208 48 208C86.34 208 121.1 193.9 148.7 171.3zM194.5 171.9L256 233.4l169.2-169.2C380 24.37 320.9 0 256 0C248.6 0 241.2 .4922 233.1 1.113C237.8 16.15 240 31.8 240 48C240 95.19 222.8 138.4 194.5 171.9zM208 48c0-14.66-2.623-28.59-6.334-42.09C158.2 15.31 118.1 35.82 86.83 64.21l84.48 84.48C193.9 121.1 208 86.34 208 48zM171.9 194.5C138.4 222.8 95.19 240 48 240c-16.2 0-31.85-2.236-46.89-6.031C.4922 241.2 0 248.6 0 256c0 64.93 24.37 124 64.21 169.2L233.4 256L171.9 194.5zM317.5 340.1L256 278.6l-169.2 169.2C131.1 487.6 191.1 512 256 512c7.438 0 14.75-.4922 22.03-1.113C274.2 495.8 272 480.2 272 464C272 416.8 289.2 373.6 317.5 340.1zM363.3 340.7l84.48 84.48c28.39-32.16 48.9-71.38 58.3-114.8C492.6 306.6 478.7 304 464 304C425.7 304 390.9 318.1 363.3 340.7zM447.8 86.83L278.6 256l61.52 61.52C373.6 289.2 416.8 272 464 272c16.2 0 31.85 2.236 46.89 6.031C511.5 270.8 512 263.4 512 256C512 191.1 487.6 131.1 447.8 86.83zM304 464c0 14.66 2.623 28.59 6.334 42.09c43.46-9.4 82.67-29.91 114.8-58.3l-84.48-84.48C318.1 390.9 304 425.7 304 464z"/></svg>
"""
Objects.insert(objectName="car",object=car).execute()
Objects.insert(objectName="ball",object=ball).execute()
print("done")

# explain the topic Rise of Mass Production and Consumption?
# explain the topic Wartime Transformations?