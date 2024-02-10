import pygame
import os

FILENAME = "/Users/teppo/repo/aileon/gfx/menu001.kla"

COLOR_BLACK = 0
COLOR_WHITE = 1
COLOR_RED = 2
COLOR_CYAN = 3
COLOR_PURPLE = 4
COLOR_GREEN = 5
COLOR_BLUE = 6
COLOR_YELLOW = 7
COLOR_ORANGE = 8
COLOR_BROWN = 9
COLOR_LIGHTRED = 10
COLOR_DARKGREY = 11
COLOR_GREY = 12
COLOR_LIGHTGREEN = 13
COLOR_LIGHTBLUE = 14
COLOR_LIGHTGREY = 15

last_mouse_x, last_mouse_y = 0, 0

c64_palette = [
    ('Black', (0, 0, 0)),
    ('White', (255, 255, 255)),
    ('Red', (136, 0, 0)),
    ('Cyan', (170, 255, 238)),
    ('Purple', (204, 68, 204)),
    ('Green', (0, 204, 85)),
    ('Blue', (0, 0, 170)),
    ('Yellow', (238, 238, 119)),
    ('Orange', (221, 136, 85)),
    ('Brown', (102, 68, 0)),
    ('L Red', (255, 119, 119)),
    ('D Grey', (51, 51, 51)),
    ('Grey', (119, 119, 119)),
    ('L Green', (170, 255, 102)),
    ('L Blue', (0, 136, 255)),
    ('L Grey', (187, 187, 187))
]


def load_koala(filename):
    with open(filename, "rb") as f:
        data = f.read()

    header = bytearray(data[:2])
    bitmap = bytearray(data[2:8002])
    screen_mem = bytearray(data[8002:9002])
    color_mem = bytearray(data[9002:10002])
    bgcolor = data[10002]

    color_matrix = [[None for _ in range(40)] for _ in range(25)]
    pixel_matrix = [[0 for _ in range(image_width)] for _ in range(image_height)]

    for y in range(25):
        for x in range(40):
            color_matrix[y][x] = (bgcolor, screen_mem[y * 40 + x] >> 4, screen_mem[y * 40 + x] & 0xf, color_mem[y * 40 + x])

    for y in range(200):
        for x in range(160):
            addr = 320 * (y >> 3) + (y & 0x07) + 2*(x & 0xfc)
            byte = bitmap[addr]
            value = (byte >> (2 * (3 - (x & 0x3)))) & 0x03
            pixel_matrix[y][x] = value

    return pixel_matrix, color_matrix, bgcolor, header


def save_koala(filename, pixel_matrix, color_matrix, bgcolor, load_addr):
    bitmap = bytearray(8000)

    for y in range(200):
        for x in range(160):
            addr = 320 * (y >> 3) + (y & 0x07) + 2 * (x & 0xfc)
            byte = bitmap[addr]

            byte &= ([0b00111111, 0b11001111, 0b11110011, 0b11111100][(x & 0x3)])
            byte |= (pixel_matrix[y][x] << (2 * (3 - (x & 0x3))))
            bitmap[addr] = byte

    screen_mem = bytearray(1000)
    color_mem = bytearray(1000)
    for y in range(25):
        for x in range(40):
            screen_mem[y * 40 + x] = (color_matrix[y][x][1] << 4) | color_matrix[y][x][2]
            color_mem[y * 40 + x] = color_matrix[y][x][3]

    with open(filename, "wb") as f:
        f.write(load_addr)
        f.write(bitmap)
        f.write(screen_mem)
        f.write(color_mem)
        f.write(bytes([bgcolor]))


def draw_pixels():
    for y, row in enumerate(pixel_matrix):
        for x, block_color in enumerate(row):
            pygame.draw.rect(screen, c64_palette[color_matrix[y // 8][x // 4][block_color]][1], (x * block_width, y * block_height, block_width, block_height))


def draw_color_chooser():
    for i in range(4):
        palette = c64_palette[color_matrix[last_mouse_y // (block_height * 8)][last_mouse_x // (block_width * 4)][i]]
        pygame.draw.rect(screen, palette[1], (i * 100, height, 100, 40))
        if i == selected_color:
            pygame.draw.rect(screen, c64_palette[COLOR_RED][1], (i * 100, height, 100, 40), 2)
        text = font.render(palette[0], True, c64_palette[COLOR_WHITE][1])
        screen.blit(text, (i * 100 + 5, height + 5))


def draw_info():
    if mouse_y < height:
        pygame.draw.rect(screen, c64_palette[COLOR_BLACK][1], (400, height, width-500, 40))
        coord_text = font.render(f"{mouse_x // block_width} {mouse_y // block_height}", True, c64_palette[COLOR_WHITE][1])
        screen.blit(coord_text, (400, height + 5))


# Set up display
image_width, image_height = 160, 200
block_width, block_height = 8, 5
width, height = block_width * image_width, block_height * image_height

pixel_matrix, color_matrix, bgcolor, load_addr = load_koala(FILENAME)

# Initialize Pygame
pygame.init()
screen = pygame.display.set_mode((width, height+40))
pygame.display.set_caption("Block Drawing Program")

# Set up drawing variables
drawing = False
selected_color = 1

font = pygame.font.Font(None, 36)

# Main game loop
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_q:
                filename = os.path.splitext(FILENAME)[0] + "_new.kla"
                save_koala(filename, pixel_matrix, color_matrix, bgcolor, load_addr)
                running = False
            elif event.key == pygame.K_s:
                save_koala(f"new_{FILENAME}", pixel_matrix, color_matrix, bgcolor, load_addr)
        elif event.type == pygame.MOUSEBUTTONDOWN:
            # Check if the user clicked on the color chooser
            x, y = event.pos
            if y < height:
                drawing = True
            elif x < 400:
                selected_color = x // 100
        elif event.type == pygame.MOUSEBUTTONUP:
            drawing = False
        elif event.type == pygame.MOUSEMOTION:
            if drawing:
                x, y = event.pos
                block_x = x // block_width
                block_y = y // block_height
                pixel_matrix[block_y][block_x] = selected_color

    mouse_x, mouse_y = pygame.mouse.get_pos()
    if mouse_y < height:
        last_mouse_x, last_mouse_y = mouse_x, mouse_y

    # Draw the blocks
    draw_pixels()

    # Draw the color chooser
    draw_color_chooser()

    # Display current mouse coordinates
    draw_info()

    # Update the display
    pygame.display.flip()

    # Set the frame rate
    pygame.time.Clock().tick(60)


# Quit Pygame
pygame.quit()
