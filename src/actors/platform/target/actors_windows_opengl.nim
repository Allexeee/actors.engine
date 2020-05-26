# proc start*(this: GLFWWindow) = 
#     this.makeContextCurrent()
#     assert glInit()
#     log(info, "Opengl v" & $glVersionMajor & "." & $glVersionMinor)
#     glEnable(GL_BLEND)
#     glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)