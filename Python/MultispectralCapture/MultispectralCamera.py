from pyueye import ueye
import threading
from multiprocessing import Lock
import numpy as np


# Loop to send images very niceeeely!
def camera_loop(pipe):
    # We create the Camera object
    ms = MultispectralCamera()
    ms.set_pixel_clock(71)
    ms.set_fps(50)

    # We go live
    ms.go_live()
    ms.piped_acquisition(pipe)


class MultispectralCamera(object):

    # # # #  # # # #
    #  CONSTRUCTOR #
    # # # #  # # # #

    def __init__(self):
        self.cam = ueye.HIDS(0)
        self.cam_info = ueye.CAMINFO()
        self.sensor_info = ueye.SENSORINFO()
        self.image_memory = ueye.c_mem_p()
        self.memory_id = ueye.int()
        self.rect_aoi = ueye.IS_RECT()
        self.bits_per_pixel = ueye.INT(24)
        self.bytes_per_pixel = int(self.bits_per_pixel/8)
        self.pitch = ueye.INT()
        self.color_mode = ueye.INT()
        self.width = 0
        self.height = 0
        self.status = 'IDLE'
        self.data = []
        self.lock = Lock()
        self.pipe = 0
        self.offset_x = 2
        self.offset_y = 2

        self.__init_camera()
        self.__get_camera_info()
        self.__get_sensor_info()
        #self.__default()
        self.__display_mode()
        self.__get_color_mode()
        self.__get_dimensions()
        self.__memory_allocation()
        self.__set_color_mode()
        self.__set_events()
        self.__mandatory_shit()

        print("Color mode {}".format(self.color_mode))
        print("Bits per pixel {}".format(self.bits_per_pixel))
        print("Bytes per pixel {}".format(self.bytes_per_pixel))

    # # # # #  # # # # #
    #  PRIVATE METHODS #
    # # # # #  # # # # #

    # Mandatory shit #####################3
    def __mandatory_shit(self):
        self.__set_gamma(100)
        self.__disable_hot_pixel_correction(0)
        self.__disable_hdr()
        self.__disable_gain_boost()
        self.__device_feature(1)
        self.__set_black_level(0)

    def __default(self):
        if not ueye.is_ResetToDefault(self.cam) == ueye.IS_SUCCESS:
            raise RuntimeError("Could not reset to default")

    def __set_gamma(self, value=100):
        gamma = ueye.INT(int(value))
        if not ueye.is_Gamma(self.cam, ueye.IS_GAMMA_CMD_SET, gamma, ueye.sizeof(gamma)) == ueye.IS_SUCCESS:
            raise RuntimeError("IS_GAMMA_CMD_SET failed")

    def __disable_hot_pixel_correction(self, value=0):
        hotpixel = ueye.c_void_p(int(value))
        nRet = ueye.is_HotPixel(
            self.cam, ueye.IS_HOTPIXEL_DISABLE_CORRECTION, hotpixel, ueye.sizeof(hotpixel))
        if nRet != ueye.IS_SUCCESS:
            raise RuntimeError("IS_HOTPIXEL_DISABLE_CORRECTION failed")
        nRet = ueye.is_HotPixel(
            self.cam, ueye.IS_HOTPIXEL_DISABLE_SENSOR_CORRECTION, hotpixel, ueye.sizeof(hotpixel))
        if nRet != ueye.IS_SUCCESS:
            raise RuntimeError("IS_HOTPIXEL_DISABLE_SENSOR_CORRECTION failed")

    def __disable_hdr(self):
        if not ueye.is_EnableHdr(self.cam, ueye.IS_DISABLE_HDR) == ueye.IS_SUCCESS:
            raise RuntimeError("IS_DISABLE_HDR failed")

    def __disable_gain_boost(self):
        if not ueye.is_SetGainBoost(self.cam, ueye.IS_SET_GAINBOOST_OFF) == ueye.IS_SUCCESS:
            raise RuntimeError("IS_SET_GAINBOOST_OFF failed")

    def __device_feature(self, value=1):
        param = ueye.INT(int(value))
        nRet = ueye.is_DeviceFeature(
            self.cam, ueye.IS_DEVICE_FEATURE_CMD_SET_LOG_MODE, param, ueye.sizeof(param))
        if nRet != ueye.IS_SUCCESS:
            raise RuntimeError("IS_DEVICE_FEATURE_CMD_SET_LOG_MODE failed")

    #################################################

    # Camera Initialization
    def __init_camera(self):
        if not ueye.is_InitCamera(self.cam, None) == ueye.IS_SUCCESS:
            raise RuntimeError("Camera not initialized")

        print("Camera initialized")

    # Sensor Info structure
    def __get_sensor_info(self):
        if not ueye.is_GetSensorInfo(self.cam, self.sensor_info) == ueye.IS_SUCCESS:
            raise RuntimeError("Sensor Info not fetched")

        print("Sensor infor acquired")

    # Camera info structure
    def __get_camera_info(self):
        if not ueye.is_GetCameraInfo(self.cam, self.cam_info) == ueye.IS_SUCCESS:
            raise RuntimeError("Camera Info not fetched")

        print("Camera info acquired")

    # Display Mode
    def __display_mode(self):
        if not ueye.is_SetDisplayMode(self.cam, ueye.IS_SET_DM_DIB) == ueye.IS_SUCCESS:
            raise RuntimeError("Display mode error")

    # Sensor dimensions
    def __get_dimensions(self):
        if not ueye.is_AOI(self.cam,
                           ueye.IS_AOI_IMAGE_GET_AOI,
                           self.rect_aoi,
                           ueye.sizeof(self.rect_aoi)) == ueye.IS_SUCCESS:
            raise RuntimeError("Dimensions not fetched")

        self.width = self.rect_aoi.s32Width
        self.height = self.rect_aoi.s32Height

        print("Sensor dimensions acquired")

    # Image memory allocation and set up
    def __memory_allocation(self):
        if not ueye.is_AllocImageMem(self.cam,
                                     self.width,
                                     self.height,
                                     self.bits_per_pixel,
                                     self.image_memory,
                                     self.memory_id) == ueye.IS_SUCCESS:
            raise RuntimeError("Memory not allocated")

        if not ueye.is_SetImageMem(self.cam, self.image_memory, self.memory_id) == ueye.IS_SUCCESS:
            raise RuntimeError("Memory not set")

        print("Memory allocated")

    # Color mode
    def __get_color_mode(self):
        # Set the right color mode
        if int.from_bytes(self.sensor_info.nColorMode.value, byteorder='big') == ueye.IS_COLORMODE_BAYER:
            ueye.is_GetColorDepth(
                self.cam, self.bits_per_pixel, self.color_mode)
            self.bytes_per_pixel = int(self.bits_per_pixel / 8)
            print("IS_COLORMODE_BAYER: ", )
            print("\tcolor_mode: \t\t", self.color_mode)
            print("\tnBitsPerPixel: \t\t", self.bits_per_pixel)
            print("\tbytes_per_pixel: \t\t", self.bytes_per_pixel)
            print()

        elif int.from_bytes(self.sensor_info.nColorMode.value, byteorder='big') == ueye.IS_COLORMODE_CBYCRY:
            # for color camera models use RGB32 mode
            self.color_mode = ueye.IS_CM_BGRA8_PACKED
            self.bits_per_pixel = ueye.INT(32)
            self.bytes_per_pixel = int(self.bits_per_pixel / 8)
            print("IS_COLORMODE_CBYCRY: ", )
            print("\tcolor_mode: \t\t", self.color_mode)
            print("\tnBitsPerPixel: \t\t", self.bits_per_pixel)
            print("\tbytes_per_pixel: \t\t", self.bytes_per_pixel)
            print()

        elif int.from_bytes(self.sensor_info.nColorMode.value, byteorder='big') == ueye.IS_COLORMODE_MONOCHROME:
            # for color camera models use RGB32 mode
            self.color_mode = ueye.IS_CM_MONO10
            self.bits_per_pixel = ueye.INT(16)
            self.bytes_per_pixel = int(self.bits_per_pixel / 8)
            print("IS_COLORMODE_MONOCHROME: ", )
            print("\tcolor_mode: \t\t", self.color_mode)
            print("\tnBitsPerPixel: \t\t", self.bits_per_pixel)
            print("\tbytes_per_pixel: \t\t", self.bytes_per_pixel)
            print()

        else:
            self.color_mode = ueye.IS_CM_MONO8
            self.bits_per_pixel = ueye.INT(8)
            self.bytes_per_pixel = int(self.bits_per_pixel / 8)

    def __set_color_mode(self):
        ueye.is_SetColorMode(self.cam, self.color_mode)

    # Set Events
    def __set_events(self):
        if not ueye.is_EnableEvent(self.cam, ueye.IS_SET_EVENT_FRAME) == ueye.IS_SUCCESS:
            raise RuntimeError("Event not set")

        print("Events enabled")

    # Disable events
    def __disable_events(self):
        if not ueye.is_DisableEvent(self.cam, ueye.IS_SET_EVENT_FRAME) == ueye.IS_SUCCESS:
            raise RuntimeError("Event not disabled")

        print("Events disabled")

    def __set_black_level(self, level):
        bl = ueye.UINT(int(level))
        if not ueye.is_Blacklevel(self.cam, ueye.IS_BLACKLEVEL_CMD_SET_OFFSET, bl, ueye.ctypes.sizeof(bl)) == ueye.IS_SUCCESS:
            raise RuntimeError("IS_BLACKLEVEL_CMD_SET_OFFSET failed")
        return bl.value

    # Disable events
    def __exit(self):
        if not ueye.is_ExitCamera(self.cam) == ueye.IS_SUCCESS:
            raise RuntimeError("Camera is still attached")

        print("Camera detached")

    # Pick up spectral signature of a given pixel
    def __pick_up_signature(self, data, x, y):
        x_index = int(x/3)*3
        y_index = int(y/3)*3

        base_x_pos = self.offset_x + x_index
        base_y_pos = self.offset_y + y_index

        return data[base_x_pos:base_x_pos+3, base_y_pos:base_y_pos+3].flatten()

    # # # # # # # # # #
    #  PUBLIC METHODS #
    # # # # # # # # # #

    # ---------- PIXEL CLOCK --------- #
    def set_pixel_clock(self, pixel_clock):
        pc = ueye.UINT(int(pixel_clock))
        if not ueye.is_PixelClock(self.cam, ueye.IS_PIXELCLOCK_CMD_SET, pc, ueye.ctypes.sizeof(pc)) == ueye.IS_SUCCESS:
            raise RuntimeError("Pixel Clock not set")

        print("Pixel clock set")

        return pc.value

    # ---------- FPS --------- #
    def set_fps(self, fps):
        new_fps = ueye.ctypes.c_double()
        if not ueye.is_SetFrameRate(self.cam, float(fps), new_fps) == ueye.IS_SUCCESS:
            raise RuntimeError("Frame Rate not set")

        if new_fps.value != fps:
            print("Warning actual fps is", new_fps.value)
        else:
            print("Frame rate set to %8.3f" % fps)

        return new_fps.value

    # ----------- GO LIVE ---------- #
    def go_live(self):
        if not ueye.is_CaptureVideo(self.cam, ueye.IS_DONT_WAIT) == ueye.IS_SUCCESS:
            raise RuntimeError("Capture mode failed")

        if not ueye.is_InquireImageMem(self.cam,
                                       self.image_memory,
                                       self.memory_id,
                                       self.width,
                                       self.height,
                                       self.bits_per_pixel,
                                       self.pitch) == ueye.IS_SUCCESS:
            raise RuntimeError("Memory inquiry failed")

        print("Pitch is {}".format(self.pitch))
        print("Camera in live mode")

    # ---------- PIPED ACQUISITION ---------- #
    def piped_acquisition(self, pipe):
        self.status = 'RUN'
        self.pipe = pipe
        print("Acquisition started!")

        while self.status == 'RUN':

            if ueye.is_WaitEvent(self.cam, ueye.IS_SET_EVENT_FRAME, 5000) == ueye.IS_SUCCESS:
                data = ueye.get_data(self.image_memory, self.width, self.height, self.bits_per_pixel, self.pitch, False)
                frame = np.reshape(data, (self.height.value, self.width.value, self.bytes_per_pixel))
                raw_frame = (frame[:, :, 1])*256 + frame[:, :, 0]  # Image raw in 10bits
                self.pipe.send(raw_frame)

            else:
                self.status = 'IDLE'

        print("Getting out")

        self.__disable_events()
        self.__exit()
