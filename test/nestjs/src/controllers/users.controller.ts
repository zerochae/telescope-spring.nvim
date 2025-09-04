import { Controller, Get, Post, Put, Delete, Patch, Body, Param } from '@nestjs/common';

@Controller('api/users')
export class UsersController {
  @Get()
  findAll() {
    return { message: 'Get all users' };
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return { message: `Get user ${id}` };
  }

  @Post()
  create(@Body() createUserDto: any) {
    return { message: 'Create user', data: createUserDto };
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateUserDto: any) {
    return { message: `Update user ${id}`, data: updateUserDto };
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return { message: `Delete user ${id}` };
  }

  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Body() statusDto: any) {
    return { message: `Update user ${id} status`, data: statusDto };
  }
}
