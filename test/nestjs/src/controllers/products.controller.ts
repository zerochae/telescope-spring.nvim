import { Controller, Get, Post, Put, Delete, Body, Param, Query } from '@nestjs/common';

@Controller('api/v1/products')
export class ProductsController {
  @Get()
  getProducts(@Query('category') category?: string) {
    return { message: 'Get all products', category };
  }

  @Get('featured')
  getFeaturedProducts() {
    return { message: 'Get featured products' };
  }

  @Get('search')
  searchProducts(@Query('q') query: string) {
    return { message: 'Search products', query };
  }

  @Get(':productId')
  getProduct(@Param('productId') productId: string) {
    return { message: `Get product ${productId}` };
  }

  @Post()
  createProduct(@Body() product: any) {
    return { message: 'Create product', data: product };
  }

  @Put(':productId')
  updateProduct(@Param('productId') productId: string, @Body() product: any) {
    return { message: `Update product ${productId}`, data: product };
  }

  @Delete(':productId')
  deleteProduct(@Param('productId') productId: string) {
    return { message: `Delete product ${productId}` };
  }
}

// Another controller without base path
@Controller()
export class GlobalController {
  @Get('health')
  healthCheck() {
    return { status: 'ok' };
  }

  @Get('version')
  getVersion() {
    return { version: '1.0.0' };
  }
}
